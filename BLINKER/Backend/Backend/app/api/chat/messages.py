import asyncio
import jwt
from app.core.config import SECRET_KEY, ALGORITHM
from app.core.security import ENCRYPTION_KEY
from app.models.message import Message
from app.db.db import messages_collection
import logging
from logging.handlers import RotatingFileHandler
from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Depends, HTTPException, status, Request
from typing import Dict, List
from app.api.auth import oauth2_scheme
from app.api.chat.encryption import EncryptionService
logger = logging.getLogger()
file_handler = RotatingFileHandler('app.log', maxBytes=10000, backupCount=3)
file_handler.setLevel(logging.INFO)
logger.addHandler(file_handler)

router = APIRouter()

active_connections: Dict[str, WebSocket] = {}
connection_lock = asyncio.Lock()


async def get_current_user(token: str):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: str = payload.get("sub")
        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid authentication credentials")
    except jwt.PyJWTError:
        raise HTTPException(status_code=401, detail="Invalid authentication credentials")
    return user_id


encryption_service = EncryptionService(ENCRYPTION_KEY)


async def process_message(message: Message):
    # Decrypt the message contents
    decrypted_contents = encryption_service.decrypt(message.contents)

    # Store the message with decrypted contents
    message_dict = message.dict()
    message_dict['contents'] = decrypted_contents
    result = messages_collection.insert_one(message_dict)

    message_id = str(result.inserted_id)

    # Create a new Message object with the updated ID and original encrypted contents
    updated_message = Message(
        id=message_id,
        sender=message.sender,
        recipient=message.recipient,
        contents=message.contents,  # Keep the original encrypted contents
        time_stamp=message.time_stamp,
        # group_id=message.group_id
    )

    # Send to recipient if online
    if message.recipient in active_connections:
        await active_connections[message.recipient].send_json(updated_message.dict())

    return updated_message


@router.post("/send", response_model=Message)
async def send_message(message: Message):
    # Process and store the message
    updated_message = await process_message(message)

    return updated_message


@router.get("/messages/{user_id}")
async def get_messages(user_id: str):
    cursor = messages_collection.find({"recipient": user_id})
    messages = await cursor.to_list(length=None)

    # Encrypt the message contents and add the message ID
    encrypted_messages = []
    for message in messages:
        encrypted_contents = encryption_service.encrypt(message["contents"])
        message["contents"] = encrypted_contents
        message["id"] = str(message["_id"])
        del message["_id"]
        encrypted_messages.append(Message(**message))

    return encrypted_messages


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
