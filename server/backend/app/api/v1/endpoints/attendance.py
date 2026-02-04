"""
Attendance/Check-in endpoints
"""

from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime, date
from app.core.database import get_db
from app.api.dependencies import get_current_user, get_current_customer, get_current_vendor
from app.schemas.attendance import AttendanceCreate, AttendanceResponse
from app.models.other import Attendance
from app.models.booking import Booking
from app.models.gym import Gym
from app.models.user import User

router = APIRouter()

@router.post("/check-in", response_model=AttendanceResponse, status_code=status.HTTP_201_CREATED)
async def check_in(
    attendance_data: AttendanceCreate,
    current_user: User = Depends(get_current_customer),
    db: Session = Depends(get_db)
):
    """
    Check in to a booking (customer only)
    """
    # Verify booking exists and belongs to user
    booking = db.query(Booking).filter(
        Booking.id == attendance_data.booking_id,
        Booking.user_id == current_user.id
    ).first()
    
    if not booking:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Booking not found"
        )
    
    # Check if already checked in
    existing_attendance = db.query(Attendance).filter(
        Attendance.booking_id == attendance_data.booking_id
    ).first()
    
    if existing_attendance:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Already checked in for this booking"
        )
    
    # Create attendance record
    new_attendance = Attendance(
        user_id=current_user.id,
        gym_id=booking.gym_id,
        booking_id=attendance_data.booking_id,
        check_in_time=datetime.now(),
        attendance_date=date.today()
    )
    
    # Update booking status
    booking.status = "active"
    booking.checked_in_at = datetime.now()
    
    db.add(new_attendance)
    db.commit()
    db.refresh(new_attendance)
    
    return new_attendance

@router.put("/{attendance_id}/check-out", response_model=AttendanceResponse)
async def check_out(
    attendance_id: str,
    current_user: User = Depends(get_current_customer),
    db: Session = Depends(get_db)
):
    """
    Check out from gym (customer only)
    """
    attendance = db.query(Attendance).filter(
        Attendance.id == attendance_id,
        Attendance.user_id == current_user.id
    ).first()
    
    if not attendance:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Attendance record not found"
        )
    
    if attendance.check_out_time:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Already checked out"
        )
    
    attendance.check_out_time = datetime.now()
    
    # Update booking status
    if attendance.booking_id:
        booking = db.query(Booking).filter(Booking.id == attendance.booking_id).first()
        if booking:
            booking.status = "completed"
    
    db.commit()
    db.refresh(attendance)
    
    return attendance

@router.get("/my-attendance", response_model=List[AttendanceResponse])
async def get_my_attendance(
    start_date: Optional[date] = None,
    end_date: Optional[date] = None,
    current_user: User = Depends(get_current_customer),
    db: Session = Depends(get_db)
):
    """
    Get current customer's attendance history
    """
    query = db.query(Attendance).filter(Attendance.user_id == current_user.id)
    
    if start_date:
        query = query.filter(Attendance.attendance_date >= start_date)
    
    if end_date:
        query = query.filter(Attendance.attendance_date <= end_date)
    
    attendance = query.order_by(Attendance.attendance_date.desc()).all()
    return attendance

@router.get("/gym/{gym_id}", response_model=List[AttendanceResponse])
async def get_gym_attendance(
    gym_id: str,
    attendance_date: Optional[date] = None,
    current_user: User = Depends(get_current_vendor),
    db: Session = Depends(get_db)
):
    """
    Get attendance for a gym (vendor only)
    """
    # Verify gym ownership
    gym = db.query(Gym).filter(
        Gym.id == gym_id,
        Gym.vendor_id == current_user.id
    ).first()
    
    if not gym:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You don't have permission to view attendance for this gym"
        )
    
    query = db.query(Attendance).filter(Attendance.gym_id == gym_id)
    
    if attendance_date:
        query = query.filter(Attendance.attendance_date == attendance_date)
    
    attendance = query.order_by(Attendance.attendance_date.desc()).all()
    return attendance
