"""
Authentication schemas
"""

from pydantic import BaseModel, EmailStr, Field
from typing import Optional

class RegisterRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8, max_length=100)
    full_name: str = Field(min_length=2, max_length=255)
    phone: Optional[str] = Field(None, max_length=20)
    user_type: str = Field(default="customer", pattern="^(customer|vendor)$")

class RegisterResponse(BaseModel):
    access_token: str
    user_id: str
    user_type: str
    full_name: str
    profile_image_url: Optional[str]
    token_type: str = "bearer"
    message: str = "Registration successful"

class LoginRequest(BaseModel):
    email: EmailStr
    password: str
    user_type: Optional[str] = Field(None, pattern="^(customer|vendor)$")

class LoginResponse(BaseModel):
    access_token: str
    user_id: str
    user_type: str
    full_name: str
    profile_image_url: Optional[str]
    token_type: str = "bearer"

class TokenData(BaseModel):
    user_id: Optional[str] = None
    user_type: Optional[str] = None
