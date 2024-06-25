import asyncio
from fastapi import APIRouter, HTTPException, WebSocket, WebSocketDisconnect
from typing import List, Dict
from pymongo import MongoClient
from bson import ObjectId
import datetime
from app.models.receipt import Receipt
from app.db.db import client
import logging
from logging.handlers import RotatingFileHandler

router = APIRouter()
client = client
db = client['vehicle_me']
receipts_collection = db['receipts']

active_connections: Dict[str, WebSocket] = {}
connection_lock = asyncio.Lock()

# Set up logging
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
handler = RotatingFileHandler('receipts.log', maxBytes=10000, backupCount=3)
handler.setLevel(logging.INFO)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)


@router.post("/send", response_model=Receipt)
async def send_receipt(receipt: Receipt):
    logger.info(f"Received receipt: {receipt}")

    receipt_dict = receipt.to_dict()
    receipt_dict['time_stamp'] = datetime.datetime.utcnow()
    result = receipts_collection.insert_one(receipt_dict)
    receipt_dict['_id'] = result.inserted_id

    logger.info(f"Inserted receipt with ID: {result.inserted_id}")

    return Receipt.from_dict(receipt_dict)


@router.get("/{user_id}", response_model=List[Receipt])
async def get_receipts(user_id: str):
    logger.info(f"Getting receipts for user ID: {user_id}")

    receipts = list(receipts_collection.find({"recipient": user_id}))

    logger.info(f"Found {len(receipts)} receipts for user ID: {user_id}")

    return [Receipt.from_dict(receipt) for receipt in receipts]


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