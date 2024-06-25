from motor.motor_asyncio import AsyncIOMotorClient
from pymongo import MongoClient

uri = "ENTER_DB_URI"
client = MongoClient(uri)
db = client["TeleCar"]
users_collection = db["Users"]
forum_collection = db["Forum"]
auctions_collection = db["Auctions"]
tickets_collection = db["Tickets"]

motor_client = AsyncIOMotorClient("ENTER_DB_URI")
messages_db = motor_client.messages_db
receipts_db = motor_client.receipts_db
typing_events_db = motor_client.typing_events_db
#messages_collection = messages_db.messages
#receipts_collection = receipts_db.receipts
#typing_events_collection = typing_events_db.typing_events


messages_collection = db["Messages"]
receipts_collection = db["Receipts"]
typing_events_collection = db["TypingEvents"]
#groups_collection = db["Groups"]

# Send a ping to confirm a successful connection
try:
    client.admin.command('ping')
    print("Pinged your deployment. You successfully connected to MongoDB!")
except Exception as e:
    print(e)
