from pydantic import BaseModel
from typing import Optional


class Vehicle(BaseModel):
    carId: str
    year: Optional[int] = 0
    color: Optional[str] = None
    brend: Optional[str] = None
    model: Optional[str] = None
