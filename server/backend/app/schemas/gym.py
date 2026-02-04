"""
Gym schemas
"""

from pydantic import BaseModel, Field, EmailStr
from typing import Optional, List
from datetime import datetime, time
from uuid import UUID

class GymBase(BaseModel):
    name: str = Field(..., min_length=2, max_length=255)
    description: Optional[str] = None
    address: str = Field(..., min_length=5)
    city: Optional[str] = None
    state: Optional[str] = None
    zip_code: Optional[str] = None
    country: str = "India"
    latitude: Optional[float] = Field(None, ge=-90, le=90)
    longitude: Optional[float] = Field(None, ge=-180, le=180)
    phone: Optional[str] = None
    email: Optional[EmailStr] = None

class GymCreate(GymBase):
    pass

class GymUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=2, max_length=255)
    description: Optional[str] = None
    address: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    zip_code: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    phone: Optional[str] = None
    email: Optional[EmailStr] = None
    logo_url: Optional[str] = None

class GymPhotoResponse(BaseModel):
    id: UUID
    image_url: str
    display_order: int
    is_primary: bool
    
    class Config:
        from_attributes = True

class GymFacilityResponse(BaseModel):
    id: UUID
    facility_type: str
    is_available: bool
    
    class Config:
        from_attributes = True

class GymOperatingHoursResponse(BaseModel):
    id: UUID
    day_type: str
    open_time: time
    close_time: time
    is_closed: bool
    
    class Config:
        from_attributes = True

class GymResponse(GymBase):
    id: UUID
    vendor_id: UUID
    logo_url: Optional[str] = None
    rating: float
    total_reviews: int
    is_verified: bool
    status: str
    created_at: datetime
    updated_at: datetime
    photos: List[GymPhotoResponse] = []
    facilities: List[GymFacilityResponse] = []
    operating_hours: List[GymOperatingHoursResponse] = []
    
    class Config:
        from_attributes = True

class GymListResponse(BaseModel):
    id: UUID
    name: str
    address: str
    city: Optional[str]
    rating: float
    total_reviews: int
    logo_url: Optional[str] = None
    primary_image: Optional[str] = None
    min_price: Optional[float] = None
    distance_km: Optional[float] = None
    
    class Config:
        from_attributes = True

class GymSearchRequest(BaseModel):
    latitude: float = Field(..., ge=-90, le=90)
    longitude: float = Field(..., ge=-180, le=180)
    radius_km: float = Field(10.0, gt=0, le=100)
    equipment_type: Optional[str] = None
