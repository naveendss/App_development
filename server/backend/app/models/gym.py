"""
Gym model
"""

from sqlalchemy import Column, String, Text, Numeric, Integer, Boolean, Enum, TIMESTAMP, ForeignKey, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
import uuid
from app.core.database import Base

class Gym(Base):
    __tablename__ = "gyms"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    vendor_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False, index=True)
    name = Column(String(255), nullable=False)
    description = Column(Text)
    logo_url = Column(Text)
    address = Column(Text, nullable=False)
    city = Column(String(100))
    state = Column(String(100))
    zip_code = Column(String(20))
    country = Column(String(100), default='India')
    latitude = Column(Numeric(10, 8))
    longitude = Column(Numeric(11, 8))
    phone = Column(String(20))
    email = Column(String(255))
    rating = Column(Numeric(3, 2), default=0.0)
    total_reviews = Column(Integer, default=0)
    is_verified = Column(Boolean, default=False)
    status = Column(Enum('pending', 'active', 'suspended', name='gym_status_enum'), default='pending', index=True)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # Relationships
    vendor = relationship("User", back_populates="gyms", foreign_keys=[vendor_id])
    photos = relationship("GymPhoto", back_populates="gym", cascade="all, delete-orphan")
    facilities = relationship("GymFacility", back_populates="gym", cascade="all, delete-orphan")
    operating_hours = relationship("GymOperatingHours", back_populates="gym", cascade="all, delete-orphan")
    equipment = relationship("Equipment", back_populates="gym", cascade="all, delete-orphan")
    membership_passes = relationship("MembershipPass", back_populates="gym", cascade="all, delete-orphan")
    bookings = relationship("Booking", back_populates="gym")
    reviews = relationship("Review", back_populates="gym")
    posts = relationship("CommunityPost", back_populates="gym")
