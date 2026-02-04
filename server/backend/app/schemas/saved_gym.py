"""
Saved Gym schemas
"""

from pydantic import BaseModel
from datetime import datetime

class SavedGymCreate(BaseModel):
    gym_id: str

class SavedGymResponse(BaseModel):
    id: str
    user_id: str
    gym_id: str
    saved_at: datetime
    
    class Config:
        from_attributes = True
