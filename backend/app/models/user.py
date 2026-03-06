from sqlalchemy import Column, Integer, String, DateTime, func, Boolean
from sqlalchemy.orm import relationship

from app.db.base import Base
from app.models.base import TimestampMixin
from app.models.screentime import Screentime


class User(Base, TimestampMixin):
    """User model for the screen time & wellness application."""

    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    firebase_uid = Column(String(128), unique=True, index=True, nullable=True)  # From Firebase Auth
    username = Column(String(80), unique=True, index=True, nullable=False)
    email = Column(String(255), unique=True, index=True, nullable=False)
    full_name = Column(String(255), nullable=True)
    created_at = Column(DateTime, default=func.now(), nullable=False)
    screentimes = relationship(Screentime, back_populates="owner", cascade="all, delete-orphan") # Screentime in minutes
    points = Column(Integer, default=0, nullable=False)  # Green points for gamification
    membership_level = Column(String(50), default="silver", nullable=False)  # e.g. member, silver, gold