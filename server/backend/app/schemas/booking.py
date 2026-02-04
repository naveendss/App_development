"""
Booking schemas
"""

from pydantic import BaseModel, Field
from typing import Optional
from datetime import date, time, datetime
from decimal import Decimal

class TimeSlotCreate(BaseModel):
    gym_id: str
    equipment_id: Optional[str] = None
    date: date
    start_time: time
    end_time: time
    capacity: int = Field(gt=0)
    base_price: Decimal = Field(gt=0)
    surge_multiplier: Decimal = Field(default=1.0, ge=1.0)
    is_available: bool = True

class TimeSlotResponse(BaseModel):
    id: str
    gym_id: str
    equipment_id: Optional[str]
    date: date
    start_time: time
    end_time: time
    capacity: int
    booked_count: int
    base_price: Decimal
    surge_multiplier: Decimal
    is_available: bool
    created_at: datetime
    
    class Config:
        from_attributes = True

class BookingCreate(BaseModel):
    slot_id: str
    membership_id: Optional[str] = None
    equipment_station: Optional[str] = None

class BookingUpdate(BaseModel):
    status: Optional[str] = None

class BookingResponse(BaseModel):
    id: str
    user_id: str
    gym_id: str
    equipment_id: Optional[str]
    slot_id: str
    membership_id: Optional[str]
    booking_date: date
    start_time: time
    end_time: time
    equipment_station: Optional[str]
    total_price: Decimal
    status: str
    qr_code_url: Optional[str]
    checked_in_at: Optional[datetime]
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True
