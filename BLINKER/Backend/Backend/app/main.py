from fastapi import FastAPI
import uvicorn
from fastapi.middleware.cors import CORSMiddleware
from app.api import auth, users, services, forum, auctions, tickets, maps
from app.api.chat import messages, typing_events, receipts
import logging
from logging.handlers import RotatingFileHandler

logger = logging.getLogger()
app = FastAPI()

app.include_router(auth.router, prefix="/auth", tags=["auth"])
app.include_router(users.router, prefix="/users", tags=["users"])
# app.include_router(websocket.router, prefix="/ws", tags=["websocket"])
app.include_router(services.router, prefix="/services", tags=["services"])
app.include_router(forum.router, prefix="/forum", tags=["forum"])
app.include_router(auctions.router, prefix="/auctions", tags=["auctions"])
app.include_router(tickets.router, prefix="/tickets", tags=["tickets"])
app.include_router(maps.router, prefix="/maps", tags=["maps"])

# chat

app.include_router(messages.router, prefix="/messages", tags=["messages"])
app.include_router(typing_events.router, prefix="/typing_events", tags=["typing_events"])
app.include_router(receipts.router, prefix="/receipts", tags=["receipts"])

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


def start():
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)


if __name__ == "__main__":
    start()
