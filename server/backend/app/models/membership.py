"""
Membership models
"""

from sqlalchemy import Column, String, Text, Date, Integer, Numeric, Boolean, Enum, TIMESTAMP, ForeignKey, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
import uuid
from app.core.database import Base

class MembershipPass(Base):
    __tablename__ = "membership_passes"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    gym_id = Column(UUID(as_uuid=True), ForeignKey('gyms.id', ondelete='CASCADE'), nullable=False)
    name = Column(String(255), nullable=False)
    description = Column(Text)
    duration_days = Column(Integer, nullable=False)
    price = Column(Numeric(10, 2), nullable=False)
    pass_type = Column(Enum('daily', 'weekly', 'monthly', 'annual', name='pass_type_enum'), nullable=False)
    includes_equipment = Column(Boolean, default=True)
    max_bookings_per_day = Column(Integer)
    max_bookings_per_week = Column(Integer)
    is_active = Column(Boolean, default=True)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # Relationships
    gym = relationship("Gym", back_populates="membership_passes")
    user_memberships = relationship("UserMembership", back_populates="pass_type")

class UserMembership(Base):
    __tablename__ = "user_memberships"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False, index=True)
    gym_id = Column(UUID(as_uuid=True), ForeignKey('gyms.id', ondelete='CASCADE'), nullable=False, index=True)
    pass_id = Column(UUID(as_uuid=True), ForeignKey('membership_passes.id', ondelete='RESTRICT'), nullable=False)
    booking_id = Column(String(50), unique=True, nullable=False, index=True)
    start_date = Column(Date, nullable=False)
    end_date = Column(Date, nullable=False)
    status = Column(Enum('active', 'expired', 'cancelled', name='membership_status_enum'), default='active', index=True)
    payment_status = Column(Enum('pending', 'paid', 'failed', 'refunded', name='payment_status_enum'), default='pending')
    amount_paid = Column(Numeric(10, 2), nullable=False)
    qr_code_url = Column(Text)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # Relationships
    user = relationship("User", back_populates="memberships")
    gym = relationship("Gym")
    pass_type = relationship("MembershipPass", back_populates="user_memberships")
    bookings = relationship("Booking", back_populates="membership")
    attendance = relationship("Attendance", back_populates="membership")
