from fastapi import APIRouter, HTTPException, WebSocket, WebSocketDisconnect
from typing import List, Dict
from pymongo import MongoClient
from bson import ObjectId
from app.models.typingEvent import TypingEvent
from app.db.db import client
import asyncio
import logging

logger = logging.getLogger()
router = APIRouter()
client = client
db = client['vehicle_me']
typing_events_collection = db['typing_events']

# Store active WebSocket connections
active_connections: Dict[str, WebSocket] = {}
connection_lock = asyncio.Lock()


@router.websocket("/ws/{user_id}")
async def websocket_endpoint(websocket: WebSocket, user_id: str):
    await websocket.accept()
    async with connection_lock:
        active_connections[user_id] = websocket
    try:
        while True:
            await websocket.receive_text()
    except WebSocketDisconnect:
        logger.info(f"WebSocket disconnected for user: {user_id}")
    finally:
        async with connection_lock:
            active_connections.pop(user_id, None)
        logger.info(f"Removed {user_id} from active connections")


@router.post("/send_typing_event", response_model=List[TypingEvent])
async def send_typing_events(events: List[TypingEvent]):
    logger.info(f"Received typing events: {[event.dict() for event in events]}")
    try:
        event_dicts = []
        for event in events:
            event_dict = event.dict(exclude_none=True)
            event_dict['sender'] = event_dict.pop('sender')
            event_dict['chatId'] = event_dict.pop('chatId')
            event_dict['recipient'] = event_dict.pop('recipient')
            event_dict['status'] = event_dict.pop('event').value
            event_dicts.append(event_dict)

        result = typing_events_collection.insert_many(event_dicts)

        for i, event_id in enumerate(result.inserted_ids):
            event_dicts[i]['_id'] = str(event_id)
            async with connection_lock:
                if event_dicts[i]['recipient'] in active_connections:
                    await active_connections[event_dicts[i]['recipient']].send_json(event_dicts[i])

        return [TypingEvent.from_dict(event) for event in event_dicts]
    except Exception as e:
        logger.error(f"Error processing typing events: {str(e)}")
        raise HTTPException(status_code=422, detail=str(e))


# Add a new endpoint to get typing events for a user
@router.get("/typing_events/{user_id}", response_model=List[TypingEvent])
async def get_typing_events(user_id: str):
    try:
        events = list(typing_events_collection.find({"recipient": user_id}))
        for event in events:
            event['_id'] = str(event['_id'])
        return [TypingEvent.from_dict(event) for event in events]
    except Exception as e:
        logger.error(f"Error fetching typing events: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))
