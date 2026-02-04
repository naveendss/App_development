"""
Other models: GymPhoto, GymFacility, GymOperatingHours, Review, Attendance, Notification, SavedGym
"""

from sqlalchemy import Column, String, Text, Integer, Time, Boolean, Enum, TIMESTAMP, ForeignKey, func, Numeric
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
import uuid
from app.core.database import Base

class GymPhoto(Base):
    __tablename__ = "gym_photos"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    gym_id = Column(UUID(as_uuid=True), ForeignKey('gyms.id', ondelete='CASCADE'), nullable=False)
    image_url = Column(Text, nullable=False)
    display_order = Column(Integer, default=0)
    is_primary = Column(Boolean, default=False)
    uploaded_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    
    gym = relationship("Gym", back_populates="photos")

class GymFacility(Base):
    __tablename__ = "gym_facilities"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    gym_id = Column(UUID(as_uuid=True), ForeignKey('gyms.id', ondelete='CASCADE'), nullable=False)
    facility_type = Column(String(100), nullable=False)
    is_available = Column(Boolean, default=True)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    
    gym = relationship("Gym", back_populates="facilities")

class GymOperatingHours(Base):
    __tablename__ = "gym_operating_hours"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    gym_id = Column(UUID(as_uuid=True), ForeignKey('gyms.id', ondelete='CASCADE'), nullable=False)
    day_type = Column(Enum('weekday', 'weekend', name='day_type_enum'), nullable=False)
    open_time = Column(Time, nullable=False)
    close_time = Column(Time, nullable=False)
    is_closed = Column(Boolean, default=False)
    
    gym = relationship("Gym", back_populates="operating_hours")

class Review(Base):
    __tablename__ = "reviews"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False, index=True)
    gym_id = Column(UUID(as_uuid=True), ForeignKey('gyms.id', ondelete='CASCADE'), nullable=False, index=True)
    rating = Column(Integer, nullable=False)
    review_text = Column(Text)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), onupdate=func.now())
    
    user = relationship("User", back_populates="reviews")
    gym = relationship("Gym", back_populates="reviews")

class Attendance(Base):
    __tablename__ = "attendance"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False, index=True)
    gym_id = Column(UUID(as_uuid=True), ForeignKey('gyms.id', ondelete='CASCADE'), nullable=False, index=True)
    booking_id = Column(UUID(as_uuid=True), ForeignKey('bookings.id', ondelete='SET NULL'))
    membership_id = Column(UUID(as_uuid=True), ForeignKey('user_memberships.id', ondelete='SET NULL'))
    check_in_time = Column(TIMESTAMP(timezone=True), nullable=False, index=True)
    check_out_time = Column(TIMESTAMP(timezone=True))
    scanned_by_vendor_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='SET NULL'))
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    
    user = relationship("User", foreign_keys=[user_id])
    gym = relationship("Gym")
    booking = relationship("Booking", back_populates="attendance")
    membership = relationship("UserMembership", back_populates="attendance")
    scanned_by = relationship("User", foreign_keys=[scanned_by_vendor_id])

class Notification(Base):
    __tablename__ = "notifications"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False, index=True)
    title = Column(String(255), nullable=False)
    message = Column(Text, nullable=False)
    notification_type = Column(Enum('booking', 'payment', 'reminder', 'community', 'system', name='notification_type_enum'), nullable=False)
    is_read = Column(Boolean, default=False, index=True)
    related_id = Column(UUID(as_uuid=True))
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), index=True)
    
    user = relationship("User", back_populates="notifications")

class SavedGym(Base):
    __tablename__ = "saved_gyms"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False, index=True)
    gym_id = Column(UUID(as_uuid=True), ForeignKey('gyms.id', ondelete='CASCADE'), nullable=False, index=True)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    
    user = relationship("User")
    gym = relationship("Gym")
