"""
Review endpoints
"""

from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from app.core.database import get_db
from app.api.dependencies import get_current_user, get_current_customer
from app.schemas.review import ReviewCreate, ReviewResponse, ReviewUpdate
from app.models.other import Review
from app.models.gym import Gym
from app.models.user import User

router = APIRouter()

@router.post("", response_model=ReviewResponse, status_code=status.HTTP_201_CREATED)
async def create_review(
    review_data: ReviewCreate,
    current_user: User = Depends(get_current_customer),
    db: Session = Depends(get_db)
):
    """
    Create a review for a gym (customer only)
    """
    # Check if gym exists
    gym = db.query(Gym).filter(Gym.id == review_data.gym_id).first()
    if not gym:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Gym not found"
        )
    
    # Check if user already reviewed this gym
    existing_review = db.query(Review).filter(
        Review.gym_id == review_data.gym_id,
        Review.user_id == current_user.id
    ).first()
    
    if existing_review:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You have already reviewed this gym"
        )
    
    new_review = Review(
        user_id=current_user.id,
        gym_id=review_data.gym_id,
        rating=review_data.rating,
        review_text=review_data.review_text
    )
    
    db.add(new_review)
    db.commit()
    db.refresh(new_review)
    
    return new_review

@router.get("/gym/{gym_id}", response_model=List[ReviewResponse])
async def get_gym_reviews(
    gym_id: str,
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db)
):
    """
    Get reviews for a gym
    """
    reviews = db.query(Review).filter(
        Review.gym_id == gym_id
    ).order_by(Review.created_at.desc()).offset(skip).limit(limit).all()
    
    return reviews

@router.get("/my-reviews", response_model=List[ReviewResponse])
async def get_my_reviews(
    current_user: User = Depends(get_current_customer),
    db: Session = Depends(get_db)
):
    """
    Get current customer's reviews
    """
    reviews = db.query(Review).filter(
        Review.user_id == current_user.id
    ).order_by(Review.created_at.desc()).all()
    
    return reviews

@router.get("/{review_id}", response_model=ReviewResponse)
async def get_review(
    review_id: str,
    db: Session = Depends(get_db)
):
    """
    Get review by ID
    """
    review = db.query(Review).filter(Review.id == review_id).first()
    
    if not review:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Review not found"
        )
    
    return review

@router.put("/{review_id}", response_model=ReviewResponse)
async def update_review(
    review_id: str,
    review_update: ReviewUpdate,
    current_user: User = Depends(get_current_customer),
    db: Session = Depends(get_db)
):
    """
    Update a review (author only)
    """
    review = db.query(Review).filter(
        Review.id == review_id,
        Review.user_id == current_user.id
    ).first()
    
    if not review:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Review not found or you don't have permission"
        )
    
    update_data = review_update.model_dump(exclude_unset=True)
    
    for field, value in update_data.items():
        setattr(review, field, value)
    
    db.commit()
    db.refresh(review)
    
    return review

@router.delete("/{review_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_review(
    review_id: str,
    current_user: User = Depends(get_current_customer),
    db: Session = Depends(get_db)
):
    """
    Delete a review (author only)
    """
    review = db.query(Review).filter(
        Review.id == review_id,
        Review.user_id == current_user.id
    ).first()
    
    if not review:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Review not found or you don't have permission"
        )
    
    db.delete(review)
    db.commit()
    
    return None
