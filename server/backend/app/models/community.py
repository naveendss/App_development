"""
Community models
"""

from sqlalchemy import Column, String, Text, Integer, Boolean, Enum, TIMESTAMP, ForeignKey, func, Numeric
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
import uuid
from app.core.database import Base

class CommunityPost(Base):
    __tablename__ = "community_posts"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    author_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False, index=True)
    gym_id = Column(UUID(as_uuid=True), ForeignKey('gyms.id', ondelete='SET NULL'))
    post_type = Column(Enum('text', 'image', 'motivation', 'event', name='post_type_enum'), nullable=False)
    content = Column(Text)
    image_url = Column(Text)
    likes_count = Column(Integer, default=0)
    comments_count = Column(Integer, default=0)
    shares_count = Column(Integer, default=0)
    is_vendor_post = Column(Boolean, default=False)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), index=True)
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # Relationships
    author = relationship("User", back_populates="posts")
    gym = relationship("Gym", back_populates="posts")
    event = relationship("CommunityEvent", back_populates="post", uselist=False)
    likes = relationship("PostLike", back_populates="post", cascade="all, delete-orphan")
    comments = relationship("PostComment", back_populates="post", cascade="all, delete-orphan")

class CommunityEvent(Base):
    __tablename__ = "community_events"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    post_id = Column(UUID(as_uuid=True), ForeignKey('community_posts.id', ondelete='CASCADE'), unique=True, nullable=False)
    event_name = Column(String(255), nullable=False)
    event_date = Column(TIMESTAMP(timezone=True), nullable=False)
    location = Column(String(255), nullable=False)
    ticket_price = Column(Numeric(10, 2), default=0.0)
    banner_image_url = Column(Text)
    description = Column(Text)
    max_attendees = Column(Integer)
    current_attendees = Column(Integer, default=0)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    
    # Relationships
    post = relationship("CommunityPost", back_populates="event")

class PostLike(Base):
    __tablename__ = "post_likes"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    post_id = Column(UUID(as_uuid=True), ForeignKey('community_posts.id', ondelete='CASCADE'), nullable=False, index=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    
    # Relationships
    post = relationship("CommunityPost", back_populates="likes")
    user = relationship("User")

class PostComment(Base):
    __tablename__ = "post_comments"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    post_id = Column(UUID(as_uuid=True), ForeignKey('community_posts.id', ondelete='CASCADE'), nullable=False, index=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    comment_text = Column(Text, nullable=False)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    
    # Relationships
    post = relationship("CommunityPost", back_populates="comments")
    user = relationship("User")
