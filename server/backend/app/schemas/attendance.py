"""
Attendance schemas
"""

from pydantic import BaseModel
from typing import Optional
from datetime import date, datetime

class AttendanceCreate(BaseModel):
    booking_id: str

class AttendanceResponse(BaseModel):
    id: str
    user_id: str
    gym_id: str
    booking_id: Optional[str]
    attendance_date: date
    check_in_time: datetime
    check_out_time: Optional[datetime]
    created_at: datetime
    
    class Config:
        from_attributes = True
