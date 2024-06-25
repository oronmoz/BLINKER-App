from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class Ticket(BaseModel):
    ticket_id: str
    fine_price: float
    pay_until: datetime
    user_email: str