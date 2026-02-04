"""
Equipment model
"""

from sqlalchemy import Column, String, Text, Numeric, Integer, Boolean, TIMESTAMP, ForeignKey, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
import uuid
from app.core.database import Base

class Equipment(Base):
    __tablename__ = "equipment"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    gym_id = Column(UUID(as_uuid=True), ForeignKey('gyms.id', ondelete='CASCADE'), nullable=False, index=True)
    name = Column(String(255), nullable=False)
    description = Column(Text)
    image_url = Column(Text)
    total_units = Column(Integer, nullable=False)
    active_units = Column(Integer, nullable=False)
    base_price_per_hour = Column(Numeric(10, 2), nullable=False)
    daily_cap_price = Column(Numeric(10, 2))
    equipment_type = Column(String(100), index=True)
    is_premium = Column(Boolean, default=False)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # Relationships
    gym = relationship("Gym", back_populates="equipment")
    time_slots = relationship("TimeSlot", back_populates="equipment")
    bookings = relationship("Booking", back_populates="equipment")
