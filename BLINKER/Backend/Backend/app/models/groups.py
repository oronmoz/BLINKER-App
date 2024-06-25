from bson import ObjectId
from pydantic import BaseModel, Field
from typing import List, Optional


class GroupChat(BaseModel):
    id: Optional[str] = Field(default=None, alias="_id")
    name: str
    created_by: str = Field(alias="createdBy")
    members: List[str]

    class Config:
        allow_population_by_field_name = True
        json_encoders = {
            ObjectId: str
        }
