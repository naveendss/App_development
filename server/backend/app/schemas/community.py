"""
Community schemas
"""

from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
from decimal import Decimal

class EventDetailsCreate(BaseModel):
    event_name: str = Field(max_length=255)
    event_date: datetime
    location: str = Field(max_length=255)
    ticket_price: Decimal = Field(default=0.0, ge=0)
    banner_image_url: Optional[str] = None
    description: Optional[str] = None
    max_attendees: Optional[int] = None

class PostCreate(BaseModel):
    gym_id: Optional[str] = None
    post_type: str
    content: Optional[str] = None
    image_url: Optional[str] = None
    event_details: Optional[EventDetailsCreate] = None

class PostUpdate(BaseModel):
    content: Optional[str] = None
    image_url: Optional[str] = None

class PostResponse(BaseModel):
    id: str
    author_id: str
    gym_id: Optional[str]
    post_type: str
    content: Optional[str]
    image_url: Optional[str]
    likes_count: int
    comments_count: int
    shares_count: int
    is_vendor_post: bool
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

class CommentCreate(BaseModel):
    comment_text: str

class CommentResponse(BaseModel):
    id: str
    post_id: str
    user_id: str
    comment_text: str
    created_at: datetime
    
    class Config:
        from_attributes = True

class EventCreate(BaseModel):
    post_id: str
    event_name: str = Field(max_length=255)
    event_date: datetime
    location: str = Field(max_length=255)
    ticket_price: Decimal = Field(default=0.0, ge=0)
    banner_image_url: Optional[str] = None
    description: Optional[str] = None
    max_attendees: Optional[int] = None

class EventResponse(BaseModel):
    id: str
    post_id: str
    event_name: str
    event_date: datetime
    location: str
    ticket_price: Decimal
    banner_image_url: Optional[str]
    description: Optional[str]
    max_attendees: Optional[int]
    current_attendees: int
    created_at: datetime
    
    class Config:
        from_attributes = True
