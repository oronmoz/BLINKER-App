from pydantic import BaseModel

class Service(BaseModel):
    id: int
    name: str
    address: str
    latitude: float
    longitude: float

