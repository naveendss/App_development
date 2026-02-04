"""
Time Slot model
"""

from sqlalchemy import Column, Date, Time, Integer, Numeric, Boolean, TIMESTAMP, ForeignKey, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
import uuid
from app.core.database import Base

class TimeSlot(Base):
    __tablename__ = "time_slots"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    gym_id = Column(UUID(as_uuid=True), ForeignKey('gyms.id', ondelete='CASCADE'), nullable=False, index=True)
    equipment_id = Column(UUID(as_uuid=True), ForeignKey('equipment.id', ondelete='CASCADE'))
    date = Column(Date, nullable=False, index=True)
    start_time = Column(Time, nullable=False)
    end_time = Column(Time, nullable=False)
    capacity = Column(Integer, nullable=False)
    booked_count = Column(Integer, default=0)
    base_price = Column(Numeric(10, 2), nullable=False)
    surge_multiplier = Column(Numeric(3, 2), default=1.0)
    is_surge_active = Column(Boolean, default=False)
    is_available = Column(Boolean, default=True)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    
    # Relationships
    gym = relationship("Gym")
    equipment = relationship("Equipment", back_populates="time_slots")
    bookings = relationship("Booking", back_populates="slot")
