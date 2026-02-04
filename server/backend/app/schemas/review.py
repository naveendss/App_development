"""
Review schemas
"""

from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

class ReviewCreate(BaseModel):
    gym_id: str
    rating: int = Field(ge=1, le=5)
    review_text: Optional[str] = None

class ReviewUpdate(BaseModel):
    rating: Optional[int] = Field(None, ge=1, le=5)
    review_text: Optional[str] = None

class ReviewResponse(BaseModel):
    id: str
    user_id: str
    gym_id: str
    rating: int
    review_text: Optional[str]
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True
