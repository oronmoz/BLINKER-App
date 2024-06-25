from pydantic import BaseModel, EmailStr
from datetime import datetime
from app.models.user import UserRegistration


class Auction(BaseModel):
    manufacturer: str
    model: str
    year: int
    kilometers: int
    price: int
    description: str
    contactName: str
    contactNumber: str
    endTime: datetime
