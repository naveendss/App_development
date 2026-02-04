"""
Payment schemas
"""

from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
from decimal import Decimal

class PaymentCreate(BaseModel):
    gym_id: Optional[str] = None
    booking_id: Optional[str] = None
    membership_id: Optional[str] = None
    amount: Decimal = Field(gt=0)
    payment_method: str
    card_last_four: Optional[str] = Field(None, max_length=4)

class PaymentUpdate(BaseModel):
    payment_status: str

class PaymentResponse(BaseModel):
    id: str
    user_id: str
    gym_id: str
    booking_id: Optional[str]
    membership_id: Optional[str]
    amount: Decimal
    currency: str
    payment_method: str
    payment_status: str
    transaction_id: Optional[str]
    card_last_four: Optional[str]
    payment_date: datetime
    created_at: datetime
    
    class Config:
        from_attributes = True
