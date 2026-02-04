"""
Payment endpoints
"""

from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime
from app.core.database import get_db
from app.api.dependencies import get_current_user, get_current_customer, get_current_vendor
from app.schemas.payment import PaymentCreate, PaymentResponse, PaymentUpdate
from app.models.payment import Payment
from app.models.booking import Booking
from app.models.gym import Gym
from app.models.user import User
import uuid

router = APIRouter()

@router.post("", response_model=PaymentResponse, status_code=status.HTTP_201_CREATED)
async def create_payment(
    payment_data: PaymentCreate,
    current_user: User = Depends(get_current_customer),
    db: Session = Depends(get_db)
):
    """
    Create a payment record (customer only)
    """
    # Verify booking ownership if booking_id provided
    if payment_data.booking_id:
        booking = db.query(Booking).filter(
            Booking.id == payment_data.booking_id,
            Booking.user_id == current_user.id
        ).first()
        
        if not booking:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Booking not found"
            )
        
        gym_id = booking.gym_id
    else:
        gym_id = payment_data.gym_id
    
    # Generate transaction ID
    transaction_id = f"TXN-{uuid.uuid4().hex[:12].upper()}"
    
    # Create payment
    new_payment = Payment(
        user_id=current_user.id,
        gym_id=gym_id,
        booking_id=payment_data.booking_id,
        membership_id=payment_data.membership_id,
        amount=payment_data.amount,
        currency="INR",
        payment_method=payment_data.payment_method,
        payment_status="pending",
        transaction_id=transaction_id,
        card_last_four=payment_data.card_last_four
    )
    
    db.add(new_payment)
    db.commit()
    db.refresh(new_payment)
    
    return new_payment

@router.get("/my-payments", response_model=List[PaymentResponse])
async def get_my_payments(
    status_filter: Optional[str] = Query(None, regex="^(pending|paid|failed|refunded)$"),
    current_user: User = Depends(get_current_customer),
    db: Session = Depends(get_db)
):
    """
    Get current customer's payment history
    """
    query = db.query(Payment).filter(Payment.user_id == current_user.id)
    
    if status_filter:
        query = query.filter(Payment.payment_status == status_filter)
    
    payments = query.order_by(Payment.payment_date.desc()).all()
    return payments

@router.get("/gym/{gym_id}", response_model=List[PaymentResponse])
async def get_gym_payments(
    gym_id: str,
    current_user: User = Depends(get_current_vendor),
    db: Session = Depends(get_db)
):
    """
    Get payments for a gym (vendor only)
    """
    # Verify gym ownership
    gym = db.query(Gym).filter(
        Gym.id == gym_id,
        Gym.vendor_id == current_user.id
    ).first()
    
    if not gym:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You don't have permission to view payments for this gym"
        )
    
    payments = db.query(Payment).filter(
        Payment.gym_id == gym_id
    ).order_by(Payment.payment_date.desc()).all()
    
    return payments

@router.get("/{payment_id}", response_model=PaymentResponse)
async def get_payment(
    payment_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get payment details by ID
    """
    payment = db.query(Payment).filter(Payment.id == payment_id).first()
    
    if not payment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Payment not found"
        )
    
    # Check permission
    if current_user.user_type == "customer" and payment.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You don't have permission to view this payment"
        )
    
    if current_user.user_type == "vendor":
        gym = db.query(Gym).filter(
            Gym.id == payment.gym_id,
            Gym.vendor_id == current_user.id
        ).first()
        if not gym:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You don't have permission to view this payment"
            )
    
    return payment

@router.put("/{payment_id}/status", response_model=PaymentResponse)
async def update_payment_status(
    payment_id: str,
    payment_update: PaymentUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Update payment status
    """
    payment = db.query(Payment).filter(Payment.id == payment_id).first()
    
    if not payment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Payment not found"
        )
    
    # Check permission
    if current_user.user_type == "customer" and payment.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You don't have permission to update this payment"
        )
    
    if current_user.user_type == "vendor":
        gym = db.query(Gym).filter(
            Gym.id == payment.gym_id,
            Gym.vendor_id == current_user.id
        ).first()
        if not gym:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You don't have permission to update this payment"
            )
    
    payment.payment_status = payment_update.payment_status
    db.commit()
    db.refresh(payment)
    
    return payment
