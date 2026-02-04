"""
Gym endpoints
"""

from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from sqlalchemy import func, or_
from typing import List, Optional
from app.core.database import get_db
from app.api.dependencies import get_current_user, get_current_vendor
from app.schemas.gym import GymCreate, GymUpdate, GymResponse, GymListResponse, GymSearchRequest
from app.models.gym import Gym
from app.models.other import GymPhoto
from app.models.membership import MembershipPass
from app.models.user import User

router = APIRouter()

@router.post("", response_model=GymResponse, status_code=status.HTTP_201_CREATED)
async def create_gym(
    gym_data: GymCreate,
    current_user: User = Depends(get_current_vendor),
    db: Session = Depends(get_db)
):
    """
    Create a new gym (vendor only)
    """
    new_gym = Gym(
        vendor_id=current_user.id,
        name=gym_data.name,
        description=gym_data.description,
        address=gym_data.address,
        city=gym_data.city,
        state=gym_data.state,
        zip_code=gym_data.zip_code,
        country=gym_data.country,
        latitude=gym_data.latitude or 0.0,
        longitude=gym_data.longitude or 0.0,
        phone=gym_data.phone,
        email=gym_data.email,
        status='active',  # Set to active immediately
        is_verified=False,
        rating=0.0,
        total_reviews=0
    )
    
    db.add(new_gym)
    db.commit()
    db.refresh(new_gym)
    
    return new_gym

@router.get("", response_model=List[GymListResponse])
async def list_gyms(
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    search: Optional[str] = None,
    city: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """
    List all active gyms with pagination and filters
    """
    query = db.query(Gym).filter(Gym.status == "active")
    
    if search:
        query = query.filter(
            or_(
                Gym.name.ilike(f"%{search}%"),
                Gym.description.ilike(f"%{search}%"),
                Gym.address.ilike(f"%{search}%")
            )
        )
    
    if city:
        query = query.filter(Gym.city.ilike(f"%{city}%"))
    
    gyms = query.offset(skip).limit(limit).all()
    
    # Add primary image and min price
    result = []
    for gym in gyms:
        primary_photo = db.query(GymPhoto).filter(
            GymPhoto.gym_id == gym.id,
            GymPhoto.is_primary == True
        ).first()
        
        min_price = db.query(func.min(MembershipPass.price)).filter(
            MembershipPass.gym_id == gym.id,
            MembershipPass.is_active == True
        ).scalar()
        
        result.append(GymListResponse(
            id=gym.id,
            name=gym.name,
            address=gym.address,
            city=gym.city,
            rating=gym.rating,
            total_reviews=gym.total_reviews,
            logo_url=gym.logo_url,
            primary_image=primary_photo.image_url if primary_photo else None,
            min_price=float(min_price) if min_price else None,
            distance_km=None
        ))
    
    return result

@router.post("/search", response_model=List[GymListResponse])
async def search_gyms_by_location(
    search_request: GymSearchRequest,
    db: Session = Depends(get_db)
):
    """
    Search gyms by location with distance calculation
    """
    # Haversine formula for distance calculation
    lat = search_request.latitude
    lng = search_request.longitude
    radius = search_request.radius_km
    
    # Simple distance calculation (approximate)
    gyms = db.query(Gym).filter(
        Gym.status == "active",
        Gym.latitude.isnot(None),
        Gym.longitude.isnot(None)
    ).all()
    
    result = []
    for gym in gyms:
        # Calculate distance using Haversine formula
        from math import radians, cos, sin, asin, sqrt
        
        lon1, lat1, lon2, lat2 = map(radians, [lng, lat, float(gym.longitude), float(gym.latitude)])
        dlon = lon2 - lon1
        dlat = lat2 - lat1
        a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
        c = 2 * asin(sqrt(a))
        distance_km = 6371 * c  # Radius of earth in kilometers
        
        if distance_km <= radius:
            primary_photo = db.query(GymPhoto).filter(
                GymPhoto.gym_id == gym.id,
                GymPhoto.is_primary == True
            ).first()
            
            min_price = db.query(func.min(MembershipPass.price)).filter(
                MembershipPass.gym_id == gym.id,
                MembershipPass.is_active == True
            ).scalar()
            
            result.append(GymListResponse(
                id=gym.id,
                name=gym.name,
                address=gym.address,
                city=gym.city,
                rating=gym.rating,
                total_reviews=gym.total_reviews,
                logo_url=gym.logo_url,
                primary_image=primary_photo.image_url if primary_photo else None,
                min_price=float(min_price) if min_price else None,
                distance_km=round(distance_km, 2)
            ))
    
    # Sort by distance
    result.sort(key=lambda x: x.distance_km)
    
    return result

@router.get("/{gym_id}", response_model=GymResponse)
async def get_gym(gym_id: str, db: Session = Depends(get_db)):
    """
    Get gym details by ID
    """
    gym = db.query(Gym).filter(Gym.id == gym_id).first()
    
    if not gym:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Gym not found"
        )
    
    return gym

@router.put("/{gym_id}", response_model=GymResponse)
async def update_gym(
    gym_id: str,
    gym_update: GymUpdate,
    current_user: User = Depends(get_current_vendor),
    db: Session = Depends(get_db)
):
    """
    Update gym (vendor only, own gyms)
    """
    gym = db.query(Gym).filter(
        Gym.id == gym_id,
        Gym.vendor_id == current_user.id
    ).first()
    
    if not gym:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Gym not found or you don't have permission"
        )
    
    update_data = gym_update.model_dump(exclude_unset=True)
    
    for field, value in update_data.items():
        setattr(gym, field, value)
    
    db.commit()
    db.refresh(gym)
    
    return gym

@router.delete("/{gym_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_gym(
    gym_id: str,
    current_user: User = Depends(get_current_vendor),
    db: Session = Depends(get_db)
):
    """
    Delete gym (vendor only, own gyms)
    """
    gym = db.query(Gym).filter(
        Gym.id == gym_id,
        Gym.vendor_id == current_user.id
    ).first()
    
    if not gym:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Gym not found or you don't have permission"
        )
    
    db.delete(gym)
    db.commit()
    
    return None

@router.get("/vendor/my-gyms", response_model=List[GymResponse])
async def get_vendor_gyms(
    current_user: User = Depends(get_current_vendor),
    db: Session = Depends(get_db)
):
    """
    Get all gyms owned by current vendor
    """
    gyms = db.query(Gym).filter(Gym.vendor_id == current_user.id).all()
    return gyms
