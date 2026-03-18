from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship

from app.db.base import Base
from app.models.base import TimestampMixin
from app.models.screentime import Screentime

class User(Base, TimestampMixin):
    """User model for the Screen2Green application."""

    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    
    # Định danh từ Firebase Auth
    firebase_uid = Column(String(128), unique=True, index=True, nullable=True)  
    
    # Thông tin cá nhân
    username = Column(String(80), unique=True, index=True, nullable=False)
    email = Column(String(255), unique=True, index=True, nullable=False)
    full_name = Column(String(255), nullable=True)
    
    # (Đã lược bỏ created_at ở đây vì TimestampMixin thường đã cung cấp sẵn 
    # cả created_at và updated_at. Việc khai báo lại sẽ gây trùng lặp).
    
    # Gamification & Rewards (Hệ thống điểm xanh)
    points = Column(Integer, default=0, nullable=False)  
    membership_level = Column(String(50), default="The Seed", nullable=False) 
    
    # ==========================================
    # QUAN HỆ VỚI CÁC BẢNG KHÁC (RELATIONSHIPS)
    # ==========================================
    tree_planted = Column(Integer, default=0, nullable=False)  
    
    screentimes = relationship(
        "Screentime",
        back_populates="owner",
        cascade="all, delete-orphan"
    )

    trees = relationship(
        "Tree",
        back_populates="owner",
        cascade="all, delete-orphan"
    )
