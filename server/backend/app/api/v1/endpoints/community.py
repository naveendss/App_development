"""
Community endpoints
"""

from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from app.core.database import get_db
from app.api.dependencies import get_current_user
from app.schemas.community import (
    PostCreate, PostResponse, PostUpdate, 
    CommentCreate, CommentResponse,
    EventCreate, EventResponse
)
from app.models.community import CommunityPost, PostLike, PostComment, CommunityEvent
from app.models.gym import Gym
from app.models.user import User

router = APIRouter()

@router.post("/posts", response_model=PostResponse, status_code=status.HTTP_201_CREATED)
async def create_post(
    post_data: PostCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Create a community post
    """
    # Check if vendor posting for their gym
    is_vendor_post = False
    if post_data.gym_id and current_user.user_type == "vendor":
        gym = db.query(Gym).filter(
            Gym.id == post_data.gym_id,
            Gym.vendor_id == current_user.id
        ).first()
        if gym:
            is_vendor_post = True
    
    new_post = CommunityPost(
        author_id=current_user.id,
        gym_id=post_data.gym_id,
        post_type=post_data.post_type,
        content=post_data.content,
        image_url=post_data.image_url,
        is_vendor_post=is_vendor_post
    )
    
    db.add(new_post)
    db.commit()
    db.refresh(new_post)
    
    # If event post, create event details
    if post_data.post_type == "event" and post_data.event_details:
        event = CommunityEvent(
            post_id=new_post.id,
            **post_data.event_details.model_dump()
        )
        db.add(event)
        db.commit()
    
    return new_post

@router.get("/posts", response_model=List[PostResponse])
async def get_posts(
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    post_type: Optional[str] = None,
    gym_id: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """
    Get community posts feed
    """
    query = db.query(CommunityPost)
    
    if post_type:
        query = query.filter(CommunityPost.post_type == post_type)
    
    if gym_id:
        query = query.filter(CommunityPost.gym_id == gym_id)
    
    posts = query.order_by(CommunityPost.created_at.desc()).offset(skip).limit(limit).all()
    return posts

@router.get("/posts/{post_id}", response_model=PostResponse)
async def get_post(
    post_id: str,
    db: Session = Depends(get_db)
):
    """
    Get post by ID
    """
    post = db.query(CommunityPost).filter(CommunityPost.id == post_id).first()
    
    if not post:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Post not found"
        )
    
    return post

@router.delete("/posts/{post_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_post(
    post_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Delete a post (author only)
    """
    post = db.query(CommunityPost).filter(
        CommunityPost.id == post_id,
        CommunityPost.author_id == current_user.id
    ).first()
    
    if not post:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Post not found or you don't have permission"
        )
    
    db.delete(post)
    db.commit()
    
    return None

@router.post("/posts/{post_id}/like", status_code=status.HTTP_201_CREATED)
async def like_post(
    post_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Like a post
    """
    # Check if post exists
    post = db.query(CommunityPost).filter(CommunityPost.id == post_id).first()
    if not post:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Post not found"
        )
    
    # Check if already liked
    existing_like = db.query(PostLike).filter(
        PostLike.post_id == post_id,
        PostLike.user_id == current_user.id
    ).first()
    
    if existing_like:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You already liked this post"
        )
    
    new_like = PostLike(post_id=post_id, user_id=current_user.id)
    db.add(new_like)
    db.commit()
    
    return {"message": "Post liked successfully"}

@router.delete("/posts/{post_id}/like", status_code=status.HTTP_204_NO_CONTENT)
async def unlike_post(
    post_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Unlike a post
    """
    like = db.query(PostLike).filter(
        PostLike.post_id == post_id,
        PostLike.user_id == current_user.id
    ).first()
    
    if not like:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Like not found"
        )
    
    db.delete(like)
    db.commit()
    
    return None

@router.post("/posts/{post_id}/comments", response_model=CommentResponse, status_code=status.HTTP_201_CREATED)
async def create_comment(
    post_id: str,
    comment_data: CommentCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Comment on a post
    """
    # Check if post exists
    post = db.query(CommunityPost).filter(CommunityPost.id == post_id).first()
    if not post:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Post not found"
        )
    
    new_comment = PostComment(
        post_id=post_id,
        user_id=current_user.id,
        comment_text=comment_data.comment_text
    )
    
    db.add(new_comment)
    db.commit()
    db.refresh(new_comment)
    
    return new_comment

@router.get("/posts/{post_id}/comments", response_model=List[CommentResponse])
async def get_post_comments(
    post_id: str,
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    db: Session = Depends(get_db)
):
    """
    Get comments for a post
    """
    comments = db.query(PostComment).filter(
        PostComment.post_id == post_id
    ).order_by(PostComment.created_at.desc()).offset(skip).limit(limit).all()
    
    return comments

@router.get("/events", response_model=List[EventResponse])
async def get_events(
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db)
):
    """
    Get upcoming events
    """
    events = db.query(CommunityEvent).join(CommunityPost).order_by(
        CommunityEvent.event_date.asc()
    ).offset(skip).limit(limit).all()
    
    return events
