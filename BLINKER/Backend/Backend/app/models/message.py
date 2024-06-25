import datetime
from typing import Annotated, Optional

from pydantic import BaseModel, Field, BeforeValidator

PyObjectId = Annotated[str, BeforeValidator(str)]


class Message(BaseModel):
    sender: str
    recipient: str
    time_stamp: str
    contents: str
    id: Optional[PyObjectId] = Field(alias="_id", default=None)

    @classmethod
    def from_dict(cls, data):
        return cls(**data)

    def to_dict(self):
        return self.dict()
