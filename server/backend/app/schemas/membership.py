"""
Membership schemas
"""

from pydantic import BaseModel, Field
from typing import Optional
from datetime import date, datetime
from decimal import Decimal

class MembershipPassCreate(BaseModel):
    gym_id: str
    name: str = Field(max_length=255)
    description: Optional[str] = None
    pass_type: str
    duration_days: int = Field(gt=0)
    price: Decimal = Field(gt=0)
    max_bookings_per_day: Optional[int] = None
    max_bookings_per_week: Optional[int] = None
    is_active: bool = True

class MembershipPassUpdate(BaseModel):
    name: Optional[str] = Field(None, max_length=255)
    description: Optional[str] = None
    pass_type: Optional[str] = None
    duration_days: Optional[int] = Field(None, gt=0)
    price: Optional[Decimal] = Field(None, gt=0)
    max_bookings_per_day: Optional[int] = None
    max_bookings_per_week: Optional[int] = None
    is_active: Optional[bool] = None

class MembershipPassResponse(BaseModel):
    id: str
    gym_id: str
    name: str
    description: Optional[str]
    pass_type: str
    duration_days: int
    price: Decimal
    max_bookings_per_day: Optional[int]
    max_bookings_per_week: Optional[int]
    is_active: bool
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True
        json_encoders = {
            'UUID': str
        }

class UserMembershipCreate(BaseModel):
    pass_id: str

class UserMembershipResponse(BaseModel):
    id: str
    user_id: str
    gym_id: str
    pass_id: str
    start_date: date
    end_date: date
    payment_status: str
    amount_paid: Decimal
    qr_code_url: Optional[str]
    is_active: bool
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True
