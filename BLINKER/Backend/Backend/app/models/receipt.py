from pydantic import BaseModel
import datetime


class Receipt(BaseModel):
    message_id: str
    recipient: str
    receiptStatus: str
    time_stamp: datetime.datetime

    @classmethod
    def from_dict(cls, data):
        return cls(**data)

    def to_dict(self):
        return self.dict()