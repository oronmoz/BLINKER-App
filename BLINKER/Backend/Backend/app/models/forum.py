from pydantic import BaseModel
from typing import List, Optional


class CommentCreate(BaseModel):
    post_id: str
    content: str


class Comment(BaseModel):
    user_email: str
    content: str
    created_at: str


class ForumPostCreate(BaseModel):
    title: str
    content: str
    category: str
    vehicle_model: str
    vehicle_brand: str


class ForumPost(BaseModel):
    id: str
    title: str
    content: str
    category: str
    vehicle_model: str
    vehicle_brand: str
    created_at: str
    comments: List[Comment] = []

    class Config:
        from_attributes = True


