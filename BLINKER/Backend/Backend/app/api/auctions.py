from fastapi import APIRouter, Depends, HTTPException, status
from app.models.auction import Auction
from app.models.user import UserRegistration
from app.core.security import pwd_context
from app.db.db import users_collection, auctions_collection
from bson import ObjectId
from datetime import datetime

router = APIRouter()

@router.post("/addNewAuction", status_code=status.HTTP_200_OK)
async def add_new_auction(auction_data: Auction):
    auction_doc = {
        "manufacturer": auction_data.manufacturer,
        "model": auction_data.model,
        "year": auction_data.year,
        "kilometers": auction_data.kilometers,
        "price": auction_data.price,
        "description": auction_data.description,
        "contactName": auction_data.contactName,
        "contactNumber": auction_data.contactNumber,
        "endTime": auction_data.endTime,
    }
    try:
        auctions_collection.insert_one(auction_doc)
        return {"message": "auction added successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/get_auctions", status_code=status.HTTP_200_OK)
async def get_auctions():
    try:
        auctions = list(auctions_collection.find())
        for auction in auctions:
            auction["_id"] = str(auction["_id"])  # Convert ObjectId to string
            auction["endTime"] = auction["endTime"].isoformat() if isinstance(auction["endTime"], datetime) else auction["endTime"]  # Convert endTime to ISO format if it's not already
        return auctions
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
