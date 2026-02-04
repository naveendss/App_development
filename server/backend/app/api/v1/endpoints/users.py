"""
User endpoints
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.core.database import get_db
from app.api.dependencies import get_current_user, get_current_customer
from app.schemas.user import UserResponse, UserUpdate, CustomerProfileResponse, CustomerProfileUpdate
from app.models.user import User
from app.models.customer_profile import CustomerProfile

router = APIRouter()

@router.get("/me", response_model=UserResponse)
async def get_current_user_profile(current_user: User = Depends(get_current_user)):
    """
    Get current user profile
    """
    return current_user

@router.put("/me", response_model=UserResponse)
async def update_current_user(
    user_update: UserUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Update current user profile
    """
    update_data = user_update.model_dump(exclude_unset=True)
    
    for field, value in update_data.items():
        setattr(current_user, field, value)
    
    db.commit()
    db.refresh(current_user)
    
    return current_user

@router.get("/me/customer-profile", response_model=CustomerProfileResponse)
async def get_customer_profile(
    current_user: User = Depends(get_current_customer),
    db: Session = Depends(get_db)
):
    """
    Get customer profile (only for customers)
    """
    profile = db.query(CustomerProfile).filter(CustomerProfile.user_id == current_user.id).first()
    
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Customer profile not found"
        )
    
    return profile

@router.put("/me/customer-profile", response_model=CustomerProfileResponse)
async def update_customer_profile(
    profile_update: CustomerProfileUpdate,
    current_user: User = Depends(get_current_customer),
    db: Session = Depends(get_db)
):
    """
    Update customer profile (only for customers)
    """
    profile = db.query(CustomerProfile).filter(CustomerProfile.user_id == current_user.id).first()
    
    if not profile:
        # Create profile if doesn't exist
        profile = CustomerProfile(user_id=current_user.id)
        db.add(profile)
    
    update_data = profile_update.model_dump(exclude_unset=True)
    
    for field, value in update_data.items():
        setattr(profile, field, value)
    
    db.commit()
    db.refresh(profile)
    
    return profile

@router.get("/{user_id}", response_model=UserResponse)
async def get_user_by_id(
    user_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get user by ID
    """
    user = db.query(User).filter(User.id == user_id).first()
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    return user
