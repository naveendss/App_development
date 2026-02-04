"""
Saved Gyms endpoints
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.core.database import get_db
from app.api.dependencies import get_current_customer
from app.schemas.saved_gym import SavedGymCreate, SavedGymResponse
from app.models.other import SavedGym
from app.models.gym import Gym
from app.models.user import User

router = APIRouter()

@router.post("", response_model=SavedGymResponse, status_code=status.HTTP_201_CREATED)
async def save_gym(
    saved_gym_data: SavedGymCreate,
    current_user: User = Depends(get_current_customer),
    db: Session = Depends(get_db)
):
    """
    Save/favorite a gym (customer only)
    """
    # Check if gym exists
    gym = db.query(Gym).filter(Gym.id == saved_gym_data.gym_id).first()
    if not gym:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Gym not found"
        )
    
    # Check if already saved
    existing_saved = db.query(SavedGym).filter(
        SavedGym.user_id == current_user.id,
        SavedGym.gym_id == saved_gym_data.gym_id
    ).first()
    
    if existing_saved:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Gym already saved"
        )
    
    new_saved_gym = SavedGym(
        user_id=current_user.id,
        gym_id=saved_gym_data.gym_id
    )
    
    db.add(new_saved_gym)
    db.commit()
    db.refresh(new_saved_gym)
    
    return new_saved_gym

@router.get("", response_model=List[SavedGymResponse])
async def get_saved_gyms(
    current_user: User = Depends(get_current_customer),
    db: Session = Depends(get_db)
):
    """
    Get current customer's saved gyms
    """
    saved_gyms = db.query(SavedGym).filter(
        SavedGym.user_id == current_user.id
    ).order_by(SavedGym.saved_at.desc()).all()
    
    return saved_gyms

@router.delete("/{gym_id}", status_code=status.HTTP_204_NO_CONTENT)
async def unsave_gym(
    gym_id: str,
    current_user: User = Depends(get_current_customer),
    db: Session = Depends(get_db)
):
    """
    Remove gym from saved/favorites (customer only)
    """
    saved_gym = db.query(SavedGym).filter(
        SavedGym.user_id == current_user.id,
        SavedGym.gym_id == gym_id
    ).first()
    
    if not saved_gym:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Saved gym not found"
        )
    
    db.delete(saved_gym)
    db.commit()
    
    return None
