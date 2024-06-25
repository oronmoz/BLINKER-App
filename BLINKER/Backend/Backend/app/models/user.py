from pydantic import BaseModel, BeforeValidator, EmailStr, Field
from app.models.vehicle import Vehicle
from typing import Annotated, Optional, List

PyObjectId = Annotated[str, BeforeValidator(str)]


class UserRegistration(BaseModel):
    email: EmailStr
    first_name: str
    last_name: str
    password: str
    vehicle: Vehicle
    gender: str
    last_seen: str
    is_active: Optional[bool] = True
    phone: str
    id: Optional[PyObjectId] = Field(alias="_id", default=None)


class UserLogin(BaseModel):
    email: str
    password: str
    is_active: bool


class CarIdRequest(BaseModel):
    carIds: List[str]


class EmailResponse(BaseModel):
    emails: List[str]


class EmailRequest(BaseModel):
    emails: List[str]


class EmailsRequest(BaseModel):
    emails: List[str]