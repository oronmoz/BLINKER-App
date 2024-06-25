from pydantic import BaseModel
from enum import Enum
from typing import Optional

class Typing(str, Enum):
    START = "start"
    STOP = "stop"

class TypingEvent(BaseModel):
    id: Optional[str] = None
    sender: str
    recipient: str
    event: Typing
    chatId: Optional[str] = None

    class Config:
        allow_population_by_field_name = True

    @classmethod
    def from_dict(cls, data):
        # Adjust the field names to match the Dart model
        if 'messageID' in data:
            data['sender'] = data.pop('messageID')
        if 'status' in data:
            data['event'] = data.pop('status')
        return cls(**data)

    def to_dict(self):
        result = self.dict(exclude_none=True)
        # Adjust the field names to match the Dart model
        if 'sender' in result:
            result['messageID'] = result.pop('sender')
        if 'event' in result:
            result['status'] = result.pop('event')
        return result