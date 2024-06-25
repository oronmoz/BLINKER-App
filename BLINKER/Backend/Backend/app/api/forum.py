from app.models.forum import ForumPost, ForumPostCreate
from app.db.db import forum_collection
from fastapi import APIRouter, Depends, HTTPException, status
from datetime import datetime
from app.api.users import get_current_user
from typing import List
import logging
from app.models.forum import Comment, CommentCreate
from bson import ObjectId



logger = logging.getLogger(__name__)

router = APIRouter()


@router.post("/create_posts/", response_model=ForumPost)
def create_post(post: ForumPostCreate, current_user: dict = Depends(get_current_user)):
    logger.info(f"Current User: {current_user}")
    try:
        post_dict = post.dict()
        post_dict["email"] = current_user["email"]
        post_dict["created_at"] = datetime.utcnow().isoformat()
        post_dict["comments"] = []
        result = forum_collection.insert_one(post_dict)
        new_post = forum_collection.find_one({"_id": result.inserted_id})
        return ForumPost(id=str(new_post["_id"]), **new_post)
    except Exception as e:
        logger.error(f"Error creating post: {e}")
        raise HTTPException(status_code=500, detail="Internal Server Error")
# Endpoint to read all posts


@router.get("/posts/", response_model=List[ForumPost])
def read_posts():
    try:
        posts_cursor = forum_collection.find()
        posts = []
        for post in posts_cursor:
            post["_id"] = str(post["_id"])
            if "created_at" not in post:
                post["created_at"] = "N/A"  # Or handle appropriately
            posts.append(ForumPost(id=post["_id"], **post))
        return posts
    except Exception as e:
        logger.error(f"Error reading posts: {e}")
        raise HTTPException(status_code=500, detail="Internal Server Error")


@router.post("/add_comment/")
def add_comment(comment: CommentCreate, current_user: dict = Depends(get_current_user)):
    try:
        logger.info(f"Received comment: {comment}")
        logger.info(f"Current user: {current_user}")
        comment_data = Comment(
            user_email=current_user["email"],
            content=comment.content,
            created_at=datetime.utcnow().isoformat()
        )
        result = forum_collection.update_one(
            {"_id": ObjectId(comment.post_id)},
            {"$push": {"comments": comment_data.dict()}}
        )
        if result.modified_count == 1:
            return {"message": "Comment added successfully"}
        else:
            raise HTTPException(status_code=404, detail="Post not found")
    except Exception as e:
        logger.error(f"Error adding comment: {e}")
        raise HTTPException(status_code=500, detail="Internal Server Error")