"""
Equipment endpoints
"""

from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from app.core.database import get_db
from app.api.dependencies import get_current_user, get_current_vendor
from app.schemas.equipment import EquipmentCreate, EquipmentUpdate, EquipmentResponse
from app.models.equipment import Equipment
from app.models.gym import Gym
from app.models.user import User

router = APIRouter()

@router.post("", response_model=EquipmentResponse, status_code=status.HTTP_201_CREATED)
async def create_equipment(
    equipment_data: EquipmentCreate,
    current_user: User = Depends(get_current_vendor),
    db: Session = Depends(get_db)
):
    """
    Create equipment for a gym (vendor only)
    Equipment is immediately available for customers to view and book
    """
    # Verify gym ownership
    gym = db.query(Gym).filter(
        Gym.id == equipment_data.gym_id,
        Gym.vendor_id == current_user.id
    ).first()
    
    if not gym:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You don't have permission to add equipment to this gym"
        )
    
    # Ensure gym is active so equipment is visible to customers
    if gym.status != 'active':
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Gym must be active to add equipment. Current status: " + gym.status
        )
    
    # Map schema fields to model fields
    new_equipment = Equipment(
        gym_id=equipment_data.gym_id,
        name=equipment_data.equipment_name,
        equipment_type=equipment_data.equipment_type,
        total_units=equipment_data.quantity,
        active_units=equipment_data.available_quantity or equipment_data.quantity,
        base_price_per_hour=equipment_data.hourly_rate,
        description=equipment_data.description,
        image_url=equipment_data.image_url
    )
    db.add(new_equipment)
    db.commit()
    db.refresh(new_equipment)
    
    return {
        'id': str(new_equipment.id),
        'gym_id': str(new_equipment.gym_id),
        'equipment_name': new_equipment.name,
        'equipment_type': new_equipment.equipment_type or 'general',
        'brand': equipment_data.brand,
        'model': equipment_data.model,
        'quantity': new_equipment.total_units,
        'available_quantity': new_equipment.active_units,
        'hourly_rate': new_equipment.base_price_per_hour,
        'description': new_equipment.description,
        'image_url': new_equipment.image_url,
        'is_available': new_equipment.active_units > 0,
        'created_at': new_equipment.created_at,
        'updated_at': new_equipment.updated_at
    }

@router.get("/gym/{gym_id}", response_model=List[EquipmentResponse])
async def list_gym_equipment(
    gym_id: str,
    db: Session = Depends(get_db)
):
    """
    List all equipment for a specific gym
    """
    equipment = db.query(Equipment).filter(Equipment.gym_id == gym_id).all()
    
    result = []
    for eq in equipment:
        eq_dict = {
            'id': str(eq.id),
            'gym_id': str(eq.gym_id),
            'equipment_name': eq.name,
            'equipment_type': eq.equipment_type or 'general',
            'brand': None,
            'model': None,
            'quantity': eq.total_units,
            'available_quantity': eq.active_units,
            'hourly_rate': eq.base_price_per_hour,
            'description': eq.description,
            'image_url': eq.image_url,
            'is_available': eq.active_units > 0,
            'created_at': eq.created_at,
            'updated_at': eq.updated_at
        }
        result.append(eq_dict)
    
    return result

@router.get("/{equipment_id}", response_model=EquipmentResponse)
async def get_equipment(
    equipment_id: str,
    db: Session = Depends(get_db)
):
    """
    Get equipment details by ID
    """
    equipment = db.query(Equipment).filter(Equipment.id == equipment_id).first()
    
    if not equipment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Equipment not found"
        )
    
    return {
        'id': str(equipment.id),
        'gym_id': str(equipment.gym_id),
        'equipment_name': equipment.name,
        'equipment_type': equipment.equipment_type or 'general',
        'brand': None,
        'model': None,
        'quantity': equipment.total_units,
        'available_quantity': equipment.active_units,
        'hourly_rate': equipment.base_price_per_hour,
        'description': equipment.description,
        'image_url': equipment.image_url,
        'is_available': equipment.active_units > 0,
        'created_at': equipment.created_at,
        'updated_at': equipment.updated_at
    }

@router.put("/{equipment_id}", response_model=EquipmentResponse)
async def update_equipment(
    equipment_id: str,
    equipment_update: EquipmentUpdate,
    current_user: User = Depends(get_current_vendor),
    db: Session = Depends(get_db)
):
    """
    Update equipment (vendor only)
    """
    equipment = db.query(Equipment).filter(Equipment.id == equipment_id).first()
    
    if not equipment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Equipment not found"
        )
    
    # Verify gym ownership
    gym = db.query(Gym).filter(
        Gym.id == equipment.gym_id,
        Gym.vendor_id == current_user.id
    ).first()
    
    if not gym:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You don't have permission to update this equipment"
        )
    
    update_data = equipment_update.model_dump(exclude_unset=True)
    
    # Map schema fields to model fields
    field_mapping = {
        'equipment_name': 'name',
        'quantity': 'total_units',
        'available_quantity': 'active_units',
        'hourly_rate': 'base_price_per_hour'
    }
    
    for field, value in update_data.items():
        model_field = field_mapping.get(field, field)
        if hasattr(equipment, model_field):
            setattr(equipment, model_field, value)
    
    db.commit()
    db.refresh(equipment)
    
    return {
        'id': str(equipment.id),
        'gym_id': str(equipment.gym_id),
        'equipment_name': equipment.name,
        'equipment_type': equipment.equipment_type or 'general',
        'brand': update_data.get('brand'),
        'model': update_data.get('model'),
        'quantity': equipment.total_units,
        'available_quantity': equipment.active_units,
        'hourly_rate': equipment.base_price_per_hour,
        'description': equipment.description,
        'image_url': equipment.image_url,
        'is_available': equipment.active_units > 0,
        'created_at': equipment.created_at,
        'updated_at': equipment.updated_at
    }

@router.delete("/{equipment_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_equipment(
    equipment_id: str,
    current_user: User = Depends(get_current_vendor),
    db: Session = Depends(get_db)
):
    """
    Delete equipment (vendor only)
    """
    equipment = db.query(Equipment).filter(Equipment.id == equipment_id).first()
    
    if not equipment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Equipment not found"
        )
    
    # Verify gym ownership
    gym = db.query(Gym).filter(
        Gym.id == equipment.gym_id,
        Gym.vendor_id == current_user.id
    ).first()
    
    if not gym:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You don't have permission to delete this equipment"
        )
    
    db.delete(equipment)
    db.commit()
    
    return None
