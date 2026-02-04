"""
Booking model
"""

from sqlalchemy import Column, String, Text, Date, Time, Numeric, Enum, TIMESTAMP, ForeignKey, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
import uuid
from app.core.database import Base

class Booking(Base):
    __tablename__ = "bookings"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False, index=True)
    gym_id = Column(UUID(as_uuid=True), ForeignKey('gyms.id', ondelete='CASCADE'), nullable=False, index=True)
    equipment_id = Column(UUID(as_uuid=True), ForeignKey('equipment.id', ondelete='SET NULL'))
    slot_id = Column(UUID(as_uuid=True), ForeignKey('time_slots.id', ondelete='RESTRICT'), nullable=False)
    membership_id = Column(UUID(as_uuid=True), ForeignKey('user_memberships.id', ondelete='SET NULL'))
    booking_date = Column(Date, nullable=False, index=True)
    start_time = Column(Time, nullable=False)
    end_time = Column(Time, nullable=False)
    equipment_station = Column(String(50))
    total_price = Column(Numeric(10, 2), nullable=False)
    status = Column(Enum('upcoming', 'active', 'completed', 'cancelled', name='booking_status_enum'), default='upcoming', index=True)
    qr_code_url = Column(Text)
    checked_in_at = Column(TIMESTAMP(timezone=True))
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # Relationships
    user = relationship("User", back_populates="bookings", foreign_keys=[user_id])
    gym = relationship("Gym", back_populates="bookings")
    equipment = relationship("Equipment", back_populates="bookings")
    slot = relationship("TimeSlot", back_populates="bookings")
    membership = relationship("UserMembership", back_populates="bookings")
    payment = relationship("Payment", back_populates="booking", uselist=False)
    attendance = relationship("Attendance", back_populates="booking", uselist=False)
