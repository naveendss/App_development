"""
Payment model
"""

from sqlalchemy import Column, String, Numeric, Enum, TIMESTAMP, ForeignKey, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
import uuid
from app.core.database import Base

class Payment(Base):
    __tablename__ = "payments"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False, index=True)
    gym_id = Column(UUID(as_uuid=True), ForeignKey('gyms.id', ondelete='CASCADE'), nullable=False, index=True)
    booking_id = Column(UUID(as_uuid=True), ForeignKey('bookings.id', ondelete='SET NULL'))
    membership_id = Column(UUID(as_uuid=True), ForeignKey('user_memberships.id', ondelete='SET NULL'))
    amount = Column(Numeric(10, 2), nullable=False)
    currency = Column(String(3), default='INR')
    payment_method = Column(Enum('visa', 'mastercard', 'apple_pay', 'google_pay', 'cash', name='payment_method_enum'), nullable=False)
    payment_status = Column(Enum('pending', 'paid', 'failed', 'refunded', name='payment_status_enum'), default='pending', index=True)
    transaction_id = Column(String(255), unique=True)
    card_last_four = Column(String(4))
    payment_date = Column(TIMESTAMP(timezone=True), server_default=func.now(), index=True)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    
    # Relationships
    user = relationship("User")
    gym = relationship("Gym")
    booking = relationship("Booking", back_populates="payment")
    membership = relationship("UserMembership")
