"""
Customer Profile model
"""

from sqlalchemy import Column, String, Numeric, Enum, TIMESTAMP, ForeignKey, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
import uuid
from app.core.database import Base

class CustomerProfile(Base):
    __tablename__ = "customer_profiles"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), unique=True, nullable=False)
    weight_kg = Column(Numeric(5, 2))
    height_cm = Column(Numeric(5, 2))
    fitness_level = Column(Enum('beginner', 'intermediate', 'advanced', name='fitness_level_enum'))
    fitness_goal = Column(Enum('weight-loss', 'muscle-gain', 'endurance', 'general-fitness', name='fitness_goal_enum'))
    location_lat = Column(Numeric(10, 8))
    location_lng = Column(Numeric(11, 8))
    location_name = Column(String(255))
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # Relationships
    user = relationship("User", back_populates="customer_profile")
