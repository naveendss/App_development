"""
Membership endpoints
"""

from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime, timedelta
from app.core.database import get_db
from app.api.dependencies import get_current_user, get_current_customer, get_current_vendor
from app.schemas.membership import (
    MembershipPassCreate, MembershipPassResponse, MembershipPassUpdate,
    UserMembershipCreate, UserMembershipResponse
)
from app.models.membership import MembershipPass, UserMembership
from app.models.gym import Gym
from app.models.user import User
from app.core.utils import generate_qr_code

router = APIRouter()

# Membership Pass endpoints (vendor)
@router.post("/passes", response_model=MembershipPassResponse, status_code=status.HTTP_201_CREATED)
async def create_membership_pass(
    pass_data: MembershipPassCreate,
    current_user: User = Depends(get_current_vendor),
    db: Session = Depends(get_db)
):
    """
    Create membership pass (vendor only)
    """
    # Verify gym ownership
    gym = db.query(Gym).filter(
        Gym.id == pass_data.gym_id,
        Gym.vendor_id == current_user.id
    ).first()
    
    if not gym:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You don't have permission to create passes for this gym"
        )
    
    new_pass = MembershipPass(**pass_data.model_dump())
    db.add(new_pass)
    db.commit()
    db.refresh(new_pass)
    
    return {
        'id': str(new_pass.id),
        'gym_id': str(new_pass.gym_id),
        'name': new_pass.name,
        'description': new_pass.description,
        'pass_type': new_pass.pass_type,
        'duration_days': new_pass.duration_days,
        'price': new_pass.price,
        'max_bookings_per_day': new_pass.max_bookings_per_day,
        'max_bookings_per_week': new_pass.max_bookings_per_week,
        'is_active': new_pass.is_active,
        'created_at': new_pass.created_at,
        'updated_at': new_pass.updated_at
    }

@router.get("/passes/gym/{gym_id}", response_model=List[MembershipPassResponse])
async def list_gym_passes(
    gym_id: str,
    db: Session = Depends(get_db)
):
    """
    List all membership passes for a gym
    """
    passes = db.query(MembershipPass).filter(
        MembershipPass.gym_id == gym_id,
        MembershipPass.is_active == True
    ).all()
    
    # Convert to dict and ensure UUIDs are strings
    result = []
    for pass_obj in passes:
        pass_dict = {
            'id': str(pass_obj.id),
            'gym_id': str(pass_obj.gym_id),
            'name': pass_obj.name,
            'description': pass_obj.description,
            'pass_type': pass_obj.pass_type,
            'duration_days': pass_obj.duration_days,
            'price': pass_obj.price,
            'max_bookings_per_day': pass_obj.max_bookings_per_day,
            'max_bookings_per_week': pass_obj.max_bookings_per_week,
            'is_active': pass_obj.is_active,
            'created_at': pass_obj.created_at,
            'updated_at': pass_obj.updated_at
        }
        result.append(pass_dict)
    
    return result

@router.get("/passes/{pass_id}", response_model=MembershipPassResponse)
async def get_membership_pass(
    pass_id: str,
    db: Session = Depends(get_db)
):
    """
    Get membership pass details
    """
    pass_obj = db.query(MembershipPass).filter(MembershipPass.id == pass_id).first()
    
    if not pass_obj:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Membership pass not found"
        )
    
    return {
        'id': str(pass_obj.id),
        'gym_id': str(pass_obj.gym_id),
        'name': pass_obj.name,
        'description': pass_obj.description,
        'pass_type': pass_obj.pass_type,
        'duration_days': pass_obj.duration_days,
        'price': pass_obj.price,
        'max_bookings_per_day': pass_obj.max_bookings_per_day,
        'max_bookings_per_week': pass_obj.max_bookings_per_week,
        'is_active': pass_obj.is_active,
        'created_at': pass_obj.created_at,
        'updated_at': pass_obj.updated_at
    }

@router.put("/passes/{pass_id}", response_model=MembershipPassResponse)
async def update_membership_pass(
    pass_id: str,
    pass_update: MembershipPassUpdate,
    current_user: User = Depends(get_current_vendor),
    db: Session = Depends(get_db)
):
    """
    Update membership pass (vendor only)
    """
    pass_obj = db.query(MembershipPass).filter(MembershipPass.id == pass_id).first()
    
    if not pass_obj:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Membership pass not found"
        )
    
    # Verify gym ownership
    gym = db.query(Gym).filter(
        Gym.id == pass_obj.gym_id,
        Gym.vendor_id == current_user.id
    ).first()
    
    if not gym:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You don't have permission to update this pass"
        )
    
    update_data = pass_update.model_dump(exclude_unset=True)
    
    for field, value in update_data.items():
        setattr(pass_obj, field, value)
    
    db.commit()
    db.refresh(pass_obj)
    
    return {
        'id': str(pass_obj.id),
        'gym_id': str(pass_obj.gym_id),
        'name': pass_obj.name,
        'description': pass_obj.description,
        'pass_type': pass_obj.pass_type,
        'duration_days': pass_obj.duration_days,
        'price': pass_obj.price,
        'max_bookings_per_day': pass_obj.max_bookings_per_day,
        'max_bookings_per_week': pass_obj.max_bookings_per_week,
        'is_active': pass_obj.is_active,
        'created_at': pass_obj.created_at,
        'updated_at': pass_obj.updated_at
    }

# User Membership endpoints (customer)
@router.post("/user-memberships", response_model=UserMembershipResponse, status_code=status.HTTP_201_CREATED)
async def purchase_membership(
    membership_data: UserMembershipCreate,
    current_user: User = Depends(get_current_customer),
    db: Session = Depends(get_db)
):
    """
    Purchase a membership (customer only)
    """
    # Verify pass exists
    pass_obj = db.query(MembershipPass).filter(
        MembershipPass.id == membership_data.pass_id
    ).first()
    
    if not pass_obj or not pass_obj.is_active:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Membership pass not found or inactive"
        )
    
    # Calculate dates
    start_date = datetime.now().date()
    end_date = start_date + timedelta(days=pass_obj.duration_days)
    
    # Generate QR code
    qr_data = f"membership:{current_user.id}:{pass_obj.gym_id}:{membership_data.pass_id}"
    qr_code_url = generate_qr_code(qr_data)
    
    # Create user membership
    new_membership = UserMembership(
        user_id=current_user.id,
        gym_id=pass_obj.gym_id,
        pass_id=membership_data.pass_id,
        start_date=start_date,
        end_date=end_date,
        payment_status="pending",
        amount_paid=pass_obj.price,
        qr_code_url=qr_code_url,
        is_active=False  # Will be activated after payment
    )
    
    db.add(new_membership)
    db.commit()
    db.refresh(new_membership)
    
    return new_membership

@router.get("/my-memberships", response_model=List[UserMembershipResponse])
async def get_my_memberships(
    active_only: bool = Query(False),
    current_user: User = Depends(get_current_customer),
    db: Session = Depends(get_db)
):
    """
    Get current customer's memberships
    """
    query = db.query(UserMembership).filter(UserMembership.user_id == current_user.id)
    
    if active_only:
        query = query.filter(UserMembership.is_active == True)
    
    memberships = query.order_by(UserMembership.created_at.desc()).all()
    return memberships

@router.get("/user-memberships/{membership_id}", response_model=UserMembershipResponse)
async def get_user_membership(
    membership_id: str,
    current_user: User = Depends(get_current_customer),
    db: Session = Depends(get_db)
):
    """
    Get user membership details
    """
    membership = db.query(UserMembership).filter(
        UserMembership.id == membership_id,
        UserMembership.user_id == current_user.id
    ).first()
    
    if not membership:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Membership not found"
        )
    
    return membership
