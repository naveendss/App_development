"""
User model
"""

from sqlalchemy import Column, String, Date, Enum, TIMESTAMP, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
import uuid
from app.core.database import Base

class User(Base):
    __tablename__ = "users"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    phone = Column(String(20), unique=True, index=True)
    email = Column(String(255), unique=True, nullable=False, index=True)
    password_hash = Column(String(255))
    full_name = Column(String(255), nullable=False)
    date_of_birth = Column(Date)
    gender = Column(Enum('male', 'female', 'non-binary', 'prefer-not-to-say', name='gender_enum'))
    profile_image_url = Column(String)
    user_type = Column(Enum('customer', 'vendor', name='user_type_enum'), nullable=False, index=True)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # Relationships
    customer_profile = relationship("CustomerProfile", back_populates="user", uselist=False)
    gyms = relationship("Gym", back_populates="vendor", foreign_keys="Gym.vendor_id")
    bookings = relationship("Booking", back_populates="user", foreign_keys="Booking.user_id")
    memberships = relationship("UserMembership", back_populates="user")
    posts = relationship("CommunityPost", back_populates="author")
    reviews = relationship("Review", back_populates="user")
    notifications = relationship("Notification", back_populates="user")
