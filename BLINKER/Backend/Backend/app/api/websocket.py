from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from typing import Dict

router = APIRouter()
websocket_connections: Dict[str, WebSocket] = {}

# Store active WebSocket connections
active_connections = {}


@router.websocket("/ws/{user_email}")
async def websocket_endpoint(websocket: WebSocket, user_email: str):
    await websocket.accept()
    active_connections[user_email] = websocket
    try:
        while True:
            await websocket.receive_text()
    except WebSocketDisconnect:
        del active_connections[user_email]


# Function to send message via WebSocket
async def send_message_ws(recipient: str, message: dict):
    if recipient in active_connections:
        websocket = active_connections[recipient]
        await websocket.send_json(message)


# Update the change stream to use WebSocket
def run_change_stream():
    db = client['vehicle_me']
    messages_collection = db['messages']

    with messages_collection.watch() as stream:
        for change in stream:
            if change['operationType'] == 'insert':
                new_message = change['fullDocument']
                recipient = new_message['recipient']
                new_message['content'] = decrypt(new_message['content'])
                asyncio.create_task(send_message_ws(recipient, new_message))


# Start the change stream
@router.on_event("startup")
def start_change_stream_on_startup():
    asyncio.create_task(run_change_stream())
