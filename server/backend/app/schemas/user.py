"""
User schemas
"""

from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from datetime import date, datetime
from uuid import UUID

class UserBase(BaseModel):
    phone: str = Field(..., min_length=10, max_length=20)
    email: Optional[EmailStr] = None
    full_name: str = Field(..., min_length=2, max_length=255)
    date_of_birth: Optional[date] = None
    gender: Optional[str] = Field(None, pattern="^(male|female|non-binary|prefer-not-to-say)$")
    user_type: str = Field(..., pattern="^(customer|vendor)$")

class UserCreate(UserBase):
    pass

class UserUpdate(BaseModel):
    email: Optional[EmailStr] = None
    full_name: Optional[str] = Field(None, min_length=2, max_length=255)
    date_of_birth: Optional[date] = None
    gender: Optional[str] = None
    profile_image_url: Optional[str] = None

class UserResponse(UserBase):
    id: UUID
    profile_image_url: Optional[str] = None
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

class CustomerProfileBase(BaseModel):
    weight_kg: Optional[float] = Field(None, gt=0, le=500)
    height_cm: Optional[float] = Field(None, gt=0, le=300)
    fitness_level: Optional[str] = Field(None, pattern="^(beginner|intermediate|advanced)$")
    fitness_goal: Optional[str] = Field(None, pattern="^(weight-loss|muscle-gain|endurance|general-fitness)$")
    location_lat: Optional[float] = Field(None, ge=-90, le=90)
    location_lng: Optional[float] = Field(None, ge=-180, le=180)
    location_name: Optional[str] = None

class CustomerProfileCreate(CustomerProfileBase):
    pass

class CustomerProfileUpdate(CustomerProfileBase):
    pass

class CustomerProfileResponse(CustomerProfileBase):
    id: UUID
    user_id: UUID
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True
