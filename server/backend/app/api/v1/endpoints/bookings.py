"""
Booking endpoints
"""

from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List, Optional
from datetime import date, datetime, time, timedelta
from pydantic import BaseModel
from app.core.database import get_db
from app.api.dependencies import get_current_user, get_current_customer, get_current_vendor
from app.schemas.booking import BookingCreate, BookingResponse, BookingUpdate, TimeSlotResponse, TimeSlotCreate
from app.models.booking import Booking
from app.models.time_slot import TimeSlot
from app.models.gym import Gym
from app.models.user import User
from app.core.utils import generate_qr_code

router = APIRouter()

class BulkSlotConfig(BaseModel):
    start_time: time
    end_time: time
    capacity: int
    base_price: float
    surge_multiplier: Optional[float] = 1.0

class BulkSlotRequest(BaseModel):
    gym_id: str
    equipment_id: Optional[str] = None
    start_date: date
    end_date: date
    time_slots: List[BulkSlotConfig]

@router.post("", response_model=BookingResponse, status_code=status.HTTP_201_CREATED)
async def create_booking(
    booking_data: BookingCreate,
    current_user: User = Depends(get_current_customer),
    db: Session = Depends(get_db)
):
    """
    Create a new booking (customer only)
    """
    # Check if slot exists and is available
    slot = db.query(TimeSlot).filter(TimeSlot.id == booking_data.slot_id).first()
    
    if not slot:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Time slot not found"
        )
    
    if not slot.is_available or slot.booked_count >= slot.capacity:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Time slot is not available"
        )
    
    # Calculate price
    final_price = float(slot.base_price * slot.surge_multiplier)
    
    # Generate QR code
    qr_data = f"booking:{current_user.id}:{slot.gym_id}:{booking_data.slot_id}"
    qr_code_url = generate_qr_code(qr_data)
    
    # Create booking
    new_booking = Booking(
        user_id=current_user.id,
        gym_id=slot.gym_id,
        equipment_id=slot.equipment_id,
        slot_id=booking_data.slot_id,
        membership_id=booking_data.membership_id,
        booking_date=slot.date,
        start_time=slot.start_time,
        end_time=slot.end_time,
        equipment_station=booking_data.equipment_station,
        total_price=final_price,
        qr_code_url=qr_code_url,
        status="upcoming"
    )
    
    db.add(new_booking)
    
    # CRITICAL: Update slot booked_count and availability
    slot.booked_count += 1
    if slot.booked_count >= slot.capacity:
        slot.is_available = False
    
    db.commit()
    db.refresh(new_booking)
    
    return {
        'id': str(new_booking.id),
        'user_id': str(new_booking.user_id),
        'gym_id': str(new_booking.gym_id),
        'equipment_id': str(new_booking.equipment_id) if new_booking.equipment_id else None,
        'slot_id': str(new_booking.slot_id),
        'membership_id': str(new_booking.membership_id) if new_booking.membership_id else None,
        'booking_date': new_booking.booking_date,
        'start_time': new_booking.start_time,
        'end_time': new_booking.end_time,
        'equipment_station': new_booking.equipment_station,
        'total_price': new_booking.total_price,
        'status': new_booking.status,
        'qr_code_url': new_booking.qr_code_url,
        'checked_in_at': new_booking.checked_in_at,
        'created_at': new_booking.created_at,
        'updated_at': new_booking.updated_at
    }

@router.get("/my-bookings", response_model=List[BookingResponse])
async def get_my_bookings(
    status_filter: Optional[str] = Query(None, regex="^(upcoming|active|completed|cancelled)$"),
    current_user: User = Depends(get_current_customer),
    db: Session = Depends(get_db)
):
    """
    Get current customer's bookings
    """
    query = db.query(Booking).filter(Booking.user_id == current_user.id)
    
    if status_filter:
        query = query.filter(Booking.status == status_filter)
    
    bookings = query.order_by(Booking.booking_date.desc(), Booking.start_time.desc()).all()
    
    result = []
    for booking in bookings:
        booking_dict = {
            'id': str(booking.id),
            'user_id': str(booking.user_id),
            'gym_id': str(booking.gym_id),
            'equipment_id': str(booking.equipment_id) if booking.equipment_id else None,
            'slot_id': str(booking.slot_id),
            'membership_id': str(booking.membership_id) if booking.membership_id else None,
            'booking_date': booking.booking_date,
            'start_time': booking.start_time,
            'end_time': booking.end_time,
            'equipment_station': booking.equipment_station,
            'total_price': booking.total_price,
            'status': booking.status,
            'qr_code_url': booking.qr_code_url,
            'checked_in_at': booking.checked_in_at,
            'created_at': booking.created_at,
            'updated_at': booking.updated_at
        }
        result.append(booking_dict)
    
    return result

@router.get("/gym/{gym_id}", response_model=List[BookingResponse])
async def get_gym_bookings(
    gym_id: str,
    booking_date: Optional[date] = None,
    status_filter: Optional[str] = Query(None, regex="^(upcoming|active|completed|cancelled)$"),
    current_user: User = Depends(get_current_vendor),
    db: Session = Depends(get_db)
):
    """
    Get bookings for a gym (vendor only) - shows all customer bookings
    """
    # Verify gym ownership
    gym = db.query(Gym).filter(
        Gym.id == gym_id,
        Gym.vendor_id == current_user.id
    ).first()
    
    if not gym:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You don't have permission to view bookings for this gym"
        )
    
    query = db.query(Booking).filter(Booking.gym_id == gym_id)
    
    if booking_date:
        query = query.filter(Booking.booking_date == booking_date)
    
    if status_filter:
        query = query.filter(Booking.status == status_filter)
    
    bookings = query.order_by(Booking.booking_date.desc(), Booking.start_time.desc()).all()
    
    result = []
    for booking in bookings:
        booking_dict = {
            'id': str(booking.id),
            'user_id': str(booking.user_id),
            'gym_id': str(booking.gym_id),
            'equipment_id': str(booking.equipment_id) if booking.equipment_id else None,
            'slot_id': str(booking.slot_id),
            'membership_id': str(booking.membership_id) if booking.membership_id else None,
            'booking_date': booking.booking_date,
            'start_time': booking.start_time,
            'end_time': booking.end_time,
            'equipment_station': booking.equipment_station,
            'total_price': booking.total_price,
            'status': booking.status,
            'qr_code_url': booking.qr_code_url,
            'checked_in_at': booking.checked_in_at,
            'created_at': booking.created_at,
            'updated_at': booking.updated_at
        }
        result.append(booking_dict)
    
    return result

@router.get("/{booking_id}", response_model=BookingResponse)
async def get_booking(
    booking_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get booking details by ID
    """
    booking = db.query(Booking).filter(Booking.id == booking_id).first()
    
    if not booking:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Booking not found"
        )
    
    # Check permission
    if current_user.user_type == "customer" and booking.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You don't have permission to view this booking"
        )
    
    if current_user.user_type == "vendor":
        gym = db.query(Gym).filter(
            Gym.id == booking.gym_id,
            Gym.vendor_id == current_user.id
        ).first()
        if not gym:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You don't have permission to view this booking"
            )
    
    return {
        'id': str(booking.id),
        'user_id': str(booking.user_id),
        'gym_id': str(booking.gym_id),
        'equipment_id': str(booking.equipment_id) if booking.equipment_id else None,
        'slot_id': str(booking.slot_id),
        'membership_id': str(booking.membership_id) if booking.membership_id else None,
        'booking_date': booking.booking_date,
        'start_time': booking.start_time,
        'end_time': booking.end_time,
        'equipment_station': booking.equipment_station,
        'total_price': booking.total_price,
        'status': booking.status,
        'qr_code_url': booking.qr_code_url,
        'checked_in_at': booking.checked_in_at,
        'created_at': booking.created_at,
        'updated_at': booking.updated_at
    }

@router.put("/{booking_id}/cancel", response_model=BookingResponse)
async def cancel_booking(
    booking_id: str,
    current_user: User = Depends(get_current_customer),
    db: Session = Depends(get_db)
):
    """
    Cancel a booking (customer only)
    """
    booking = db.query(Booking).filter(
        Booking.id == booking_id,
        Booking.user_id == current_user.id
    ).first()
    
    if not booking:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Booking not found"
        )
    
    if booking.status == "cancelled":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Booking is already cancelled"
        )
    
    if booking.status == "completed":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot cancel completed booking"
        )
    
    booking.status = "cancelled"
    
    # CRITICAL: Update slot availability when booking is cancelled
    slot = db.query(TimeSlot).filter(TimeSlot.id == booking.slot_id).first()
    if slot:
        slot.booked_count = max(0, slot.booked_count - 1)
        slot.is_available = True
    
    db.commit()
    db.refresh(booking)
    
    return {
        'id': str(booking.id),
        'user_id': str(booking.user_id),
        'gym_id': str(booking.gym_id),
        'equipment_id': str(booking.equipment_id) if booking.equipment_id else None,
        'slot_id': str(booking.slot_id),
        'membership_id': str(booking.membership_id) if booking.membership_id else None,
        'booking_date': booking.booking_date,
        'start_time': booking.start_time,
        'end_time': booking.end_time,
        'equipment_station': booking.equipment_station,
        'total_price': booking.total_price,
        'status': booking.status,
        'qr_code_url': booking.qr_code_url,
        'checked_in_at': booking.checked_in_at,
        'created_at': booking.created_at,
        'updated_at': booking.updated_at
    }

# Time Slots endpoints
@router.post("/slots", response_model=TimeSlotResponse, status_code=status.HTTP_201_CREATED)
async def create_time_slot(
    slot_data: TimeSlotCreate,
    current_user: User = Depends(get_current_vendor),
    db: Session = Depends(get_db)
):
    """
    Create time slot (vendor only)
    Slots are immediately available for customers to book
    """
    # Verify gym ownership
    gym = db.query(Gym).filter(
        Gym.id == slot_data.gym_id,
        Gym.vendor_id == current_user.id
    ).first()
    
    if not gym:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You don't have permission to create slots for this gym"
        )
    
    # Ensure gym is active
    if gym.status != 'active':
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Gym must be active to create slots. Current status: " + gym.status
        )
    
    # Verify equipment exists if equipment_id is provided
    if slot_data.equipment_id:
        from app.models.equipment import Equipment
        equipment = db.query(Equipment).filter(
            Equipment.id == slot_data.equipment_id,
            Equipment.gym_id == slot_data.gym_id
        ).first()
        
        if not equipment:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Equipment not found or doesn't belong to this gym"
            )
    
    new_slot = TimeSlot(**slot_data.model_dump())
    db.add(new_slot)
    db.commit()
    db.refresh(new_slot)
    
    return {
        'id': str(new_slot.id),
        'gym_id': str(new_slot.gym_id),
        'equipment_id': str(new_slot.equipment_id) if new_slot.equipment_id else None,
        'date': new_slot.date,
        'start_time': new_slot.start_time,
        'end_time': new_slot.end_time,
        'capacity': new_slot.capacity,
        'booked_count': new_slot.booked_count,
        'base_price': new_slot.base_price,
        'surge_multiplier': new_slot.surge_multiplier,
        'is_available': new_slot.is_available,
        'created_at': new_slot.created_at
    }

@router.get("/slots/available", response_model=List[TimeSlotResponse])
async def get_available_slots(
    gym_id: str,
    slot_date: date,
    equipment_id: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """
    Get available time slots for a gym/equipment on a specific date
    """
    query = db.query(TimeSlot).filter(
        TimeSlot.gym_id == gym_id,
        TimeSlot.date == slot_date,
        TimeSlot.is_available == True
    )
    
    if equipment_id:
        query = query.filter(TimeSlot.equipment_id == equipment_id)
    
    slots = query.order_by(TimeSlot.start_time).all()
    
    # Convert to dict and ensure UUIDs are strings
    result = []
    for slot in slots:
        # Calculate real-time availability
        available_spots = slot.capacity - slot.booked_count
        is_available = slot.is_available and available_spots > 0
        
        slot_dict = {
            'id': str(slot.id),
            'gym_id': str(slot.gym_id),
            'equipment_id': str(slot.equipment_id) if slot.equipment_id else None,
            'date': slot.date,
            'start_time': slot.start_time,
            'end_time': slot.end_time,
            'capacity': slot.capacity,
            'booked_count': slot.booked_count,
            'base_price': slot.base_price,
            'surge_multiplier': slot.surge_multiplier,
            'is_available': is_available,
            'created_at': slot.created_at
        }
        result.append(slot_dict)
    
    return result

@router.get("/slots/gym/{gym_id}", response_model=List[TimeSlotResponse])
async def get_gym_slots(
    gym_id: str,
    slot_date: Optional[date] = None,
    current_user: User = Depends(get_current_vendor),
    db: Session = Depends(get_db)
):
    """
    Get all time slots for a gym (vendor only) - shows booking status
    """
    # Verify gym ownership
    gym = db.query(Gym).filter(
        Gym.id == gym_id,
        Gym.vendor_id == current_user.id
    ).first()
    
    if not gym:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You don't have permission to view slots for this gym"
        )
    
    query = db.query(TimeSlot).filter(TimeSlot.gym_id == gym_id)
    
    if slot_date:
        query = query.filter(TimeSlot.date == slot_date)
    
    slots = query.order_by(TimeSlot.date, TimeSlot.start_time).all()
    
    result = []
    for slot in slots:
        available_spots = slot.capacity - slot.booked_count
        
        slot_dict = {
            'id': str(slot.id),
            'gym_id': str(slot.gym_id),
            'equipment_id': str(slot.equipment_id) if slot.equipment_id else None,
            'date': slot.date,
            'start_time': slot.start_time,
            'end_time': slot.end_time,
            'capacity': slot.capacity,
            'booked_count': slot.booked_count,
            'base_price': slot.base_price,
            'surge_multiplier': slot.surge_multiplier,
            'is_available': slot.is_available and available_spots > 0,
            'created_at': slot.created_at
        }
        result.append(slot_dict)
    
    return result


@router.get("/vendor/dashboard/{gym_id}")
async def get_vendor_dashboard_stats(
    gym_id: str,
    current_user: User = Depends(get_current_vendor),
    db: Session = Depends(get_db)
):
    """
    Get booking statistics for vendor dashboard
    """
    # Verify gym ownership
    gym = db.query(Gym).filter(
        Gym.id == gym_id,
        Gym.vendor_id == current_user.id
    ).first()
    
    if not gym:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You don't have permission to view this gym's dashboard"
        )
    
    today = date.today()
    
    # Total bookings
    total_bookings = db.query(func.count(Booking.id)).filter(
        Booking.gym_id == gym_id
    ).scalar()
    
    # Today's bookings
    today_bookings = db.query(func.count(Booking.id)).filter(
        Booking.gym_id == gym_id,
        Booking.booking_date == today
    ).scalar()
    
    # Upcoming bookings
    upcoming_bookings = db.query(func.count(Booking.id)).filter(
        Booking.gym_id == gym_id,
        Booking.status == 'upcoming',
        Booking.booking_date >= today
    ).scalar()
    
    # Active bookings
    active_bookings = db.query(func.count(Booking.id)).filter(
        Booking.gym_id == gym_id,
        Booking.status == 'active'
    ).scalar()
    
    # Total revenue
    total_revenue = db.query(func.sum(Booking.total_price)).filter(
        Booking.gym_id == gym_id,
        Booking.status.in_(['completed', 'active', 'upcoming'])
    ).scalar() or 0
    
    # Today's revenue
    today_revenue = db.query(func.sum(Booking.total_price)).filter(
        Booking.gym_id == gym_id,
        Booking.booking_date == today,
        Booking.status.in_(['completed', 'active', 'upcoming'])
    ).scalar() or 0
    
    # Available slots today
    available_slots_today = db.query(func.count(TimeSlot.id)).filter(
        TimeSlot.gym_id == gym_id,
        TimeSlot.date == today,
        TimeSlot.is_available == True
    ).scalar()
    
    # Fully booked slots today
    fully_booked_today = db.query(func.count(TimeSlot.id)).filter(
        TimeSlot.gym_id == gym_id,
        TimeSlot.date == today,
        TimeSlot.booked_count >= TimeSlot.capacity
    ).scalar()
    
    return {
        "gym_id": gym_id,
        "gym_name": gym.name,
        "statistics": {
            "total_bookings": total_bookings or 0,
            "today_bookings": today_bookings or 0,
            "upcoming_bookings": upcoming_bookings or 0,
            "active_bookings": active_bookings or 0,
            "total_revenue": float(total_revenue),
            "today_revenue": float(today_revenue),
            "available_slots_today": available_slots_today or 0,
            "fully_booked_slots_today": fully_booked_today or 0
        },
        "date": today
    }


@router.get("/vendor/booking-details/{booking_id}")
async def get_booking_with_customer_details(
    booking_id: str,
    current_user: User = Depends(get_current_vendor),
    db: Session = Depends(get_db)
):
    """
    Get booking details with customer information (vendor only)
    """
    booking = db.query(Booking).filter(Booking.id == booking_id).first()
    
    if not booking:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Booking not found"
        )
    
    # Verify gym ownership
    gym = db.query(Gym).filter(
        Gym.id == booking.gym_id,
        Gym.vendor_id == current_user.id
    ).first()
    
    if not gym:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You don't have permission to view this booking"
        )
    
    # Get customer details
    customer = db.query(User).filter(User.id == booking.user_id).first()
    
    # Get equipment details if applicable
    equipment_name = None
    if booking.equipment_id:
        from app.models.equipment import Equipment
        equipment = db.query(Equipment).filter(Equipment.id == booking.equipment_id).first()
        if equipment:
            equipment_name = equipment.name
    
    return {
        "booking": {
            "id": str(booking.id),
            "booking_date": booking.booking_date,
            "start_time": booking.start_time,
            "end_time": booking.end_time,
            "equipment_station": booking.equipment_station,
            "total_price": float(booking.total_price),
            "status": booking.status,
            "qr_code_url": booking.qr_code_url,
            "checked_in_at": booking.checked_in_at,
            "created_at": booking.created_at
        },
        "customer": {
            "id": str(customer.id),
            "full_name": customer.full_name,
            "phone": customer.phone,
            "email": customer.email,
            "profile_image_url": customer.profile_image_url
        },
        "gym": {
            "id": str(gym.id),
            "name": gym.name
        },
        "equipment": {
            "name": equipment_name
        } if equipment_name else None
    }


from pydantic import BaseModel
from typing import List

class BulkSlotConfig(BaseModel):
    start_time: time
    end_time: time
    capacity: int
    base_price: float
    surge_multiplier: Optional[float] = 1.0

class BulkSlotRequest(BaseModel):
    gym_id: str
    equipment_id: Optional[str] = None
    start_date: date
    end_date: date
    time_slots: List[BulkSlotConfig]

@router.post("/slots/bulk", status_code=status.HTTP_201_CREATED)
async def create_bulk_time_slots(
    request: BulkSlotRequest,
    current_user: User = Depends(get_current_vendor),
    db: Session = Depends(get_db)
):
    """
    Create multiple time slots for a date range (vendor only)
    Useful for setting up weekly schedules
    """
    # Verify gym ownership
    gym = db.query(Gym).filter(
        Gym.id == request.gym_id,
        Gym.vendor_id == current_user.id
    ).first()
    
    if not gym:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You don't have permission to create slots for this gym"
        )
    
    if gym.status != 'active':
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Gym must be active to create slots"
        )
    
    created_slots = []
    current_date = request.start_date
    
    from datetime import timedelta
    
    while current_date <= request.end_date:
        for slot_config in request.time_slots:
            new_slot = TimeSlot(
                gym_id=request.gym_id,
                equipment_id=request.equipment_id,
                date=current_date,
                start_time=slot_config.start_time,
                end_time=slot_config.end_time,
                capacity=slot_config.capacity,
                base_price=slot_config.base_price,
                surge_multiplier=slot_config.surge_multiplier,
                is_available=True,
                booked_count=0
            )
            db.add(new_slot)
            created_slots.append(new_slot)
        
        current_date += timedelta(days=1)
    
    db.commit()
    
    return {
        "message": f"Created {len(created_slots)} time slots",
        "slots_created": len(created_slots),
        "date_range": {
            "start": str(request.start_date),
            "end": str(request.end_date)
        }
    }
