"""
Notification schemas
"""

from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

class NotificationCreate(BaseModel):
    user_id: str
    notification_type: str
    title: str = Field(max_length=255)
    message: str
    related_entity_id: Optional[str] = None

class NotificationResponse(BaseModel):
    id: str
    user_id: str
    notification_type: str
    title: str
    message: str
    related_entity_id: Optional[str]
    is_read: bool
    created_at: datetime
    
    class Config:
        from_attributes = True
