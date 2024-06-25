from fastapi import APIRouter, WebSocket, Depends
from bson import ObjectId
from typing import List, Dict, Any
from app.db.db import client, groups_collection

router = APIRouter()
client = client
db = client['vehicle_me']


class MessageGroup:
    def __init__(self, id: str, members: List[str], created_by: str, received_by: List[str] = None):
        self.id = id
        self.members = members
        self.created_by = created_by
        self.received_by = received_by or []

    @classmethod
    def from_dict(cls, data: Dict[str, Any]):
        return cls(
            id=str(data['_id']),
            members=data['members'],
            created_by=data['created_by'],
            received_by=data.get('received_by', [])
        )

    def to_dict(self):
        return {
            'members': self.members,
            'created_by': self.created_by,
            'received_by': self.received_by
        }


class MessageGroupService:
    def __init__(self):
        self.change_streams = {}

    async def create(self, group: MessageGroup):
        result = await groups_collection.insert_one(group.to_dict())
        group.id = str(result.inserted_id)
        return group

    async def groups(self, user_id: str, websocket: WebSocket):
        pipeline = [
            {
                '$match': {
                    '$and': [
                        {'members': user_id},
                        {'created_by': {'$ne': user_id}},
                        {'$or': [
                            {'received_by': {'$exists': False}},
                            {'received_by': {'$ne': user_id}}
                        ]}
                    ]
                }
            }
        ]

        async with groups_collection.watch(pipeline) as change_stream:
            self.change_streams[user_id] = change_stream
            async for change in change_stream:
                if change['operationType'] in ['insert', 'update']:
                    group = MessageGroup.from_dict(change['fullDocument'])
                    await websocket.send_json(group.to_dict())
                    await self._update_when_received_group_created(group, user_id)

    async def _update_when_received_group_created(self, group: MessageGroup, user_id: str):
        result = await groups_collection.find_one_and_update(
            {'_id': ObjectId(group.id)},
            {'$addToSet': {'received_by': user_id}},
            return_document=True
        )
        if result:
            await self._remove_group_when_delivered_to_all(result)

    async def _remove_group_when_delivered_to_all(self, group_data: Dict[str, Any]):
        members = group_data['members']
        already_received = group_data.get('received_by', [])
        if len(members) <= len(already_received):
            await groups_collection.delete_one({'_id': group_data['_id']})

    async def dispose(self, user_id: str):
        if user_id in self.change_streams:
            await self.change_streams[user_id].close()
            del self.change_streams[user_id]


message_group_service = MessageGroupService()


@router.post("/create_group")
async def create_group(group: Dict[str, Any]):
    message_group = MessageGroup.from_dict(group)
    created_group = await message_group_service.create(message_group)
    return created_group.to_dict()


@router.websocket("/ws/groups/{user_id}")
async def websocket_groups(websocket: WebSocket, user_id: str):
    await websocket.accept()
    try:
        await message_group_service.groups(user_id, websocket)
    finally:
        await message_group_service.dispose(user_id)
