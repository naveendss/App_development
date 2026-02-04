"""
Equipment schemas
"""

from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
from decimal import Decimal

class EquipmentCreate(BaseModel):
    gym_id: str
    equipment_name: str = Field(max_length=255)
    equipment_type: str
    brand: Optional[str] = Field(None, max_length=100)
    model: Optional[str] = Field(None, max_length=100)
    quantity: int = Field(gt=0)
    available_quantity: Optional[int] = None
    hourly_rate: Decimal = Field(gt=0)
    description: Optional[str] = None
    image_url: Optional[str] = None
    is_available: bool = True

class EquipmentUpdate(BaseModel):
    equipment_name: Optional[str] = Field(None, max_length=255)
    equipment_type: Optional[str] = None
    brand: Optional[str] = Field(None, max_length=100)
    model: Optional[str] = Field(None, max_length=100)
    quantity: Optional[int] = Field(None, gt=0)
    available_quantity: Optional[int] = None
    hourly_rate: Optional[Decimal] = Field(None, gt=0)
    description: Optional[str] = None
    image_url: Optional[str] = None
    is_available: Optional[bool] = None

class EquipmentResponse(BaseModel):
    id: str
    gym_id: str
    equipment_name: str
    equipment_type: str
    brand: Optional[str]
    model: Optional[str]
    quantity: int
    available_quantity: int
    hourly_rate: Decimal
    description: Optional[str]
    image_url: Optional[str]
    is_available: bool
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True
