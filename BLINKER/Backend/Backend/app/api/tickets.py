from fastapi import FastAPI, HTTPException, Depends, APIRouter
from pydantic import BaseModel
from pymongo import MongoClient
from bson.objectid import ObjectId
from typing import List
from datetime import date
from app.models.ticket import Ticket
from app.db.db import tickets_collection

router = APIRouter()


@router.post("/tickets/", response_model=Ticket)
def create_ticket(ticket: Ticket):
    result = tickets_collection.insert_one(ticket.dict())
    if result.inserted_id:
        return ticket
    raise HTTPException(status_code=500, detail="Ticket creation failed")


@router.get("/tickets/{user_email}", response_model=List[Ticket])
def get_tickets(user_email: str):
    tickets = list(tickets_collection.find({"user_email": user_email}))
    return tickets


@router.delete("/tickets/{ticket_id}", response_model=dict)
def delete_ticket(ticket_id: str):
    result = tickets_collection.delete_one({"ticket_id": ticket_id})
    if result.deleted_count == 1:
        return {"status": "Ticket deleted"}
    raise HTTPException(status_code=404, detail="Ticket not found")
