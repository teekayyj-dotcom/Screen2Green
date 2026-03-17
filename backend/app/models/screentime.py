from sqlalchemy import Column, Integer, Float, Date, DateTime, ForeignKey, UniqueConstraint
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from datetime import date

from app.db.base import Base

class Screentime(Base):
    """
    Lưu trữ lịch sử thời gian sử dụng màn hình theo ngày của user.
    Hỗ trợ mô hình Hybrid: Phân tách tổng thời gian và thời gian Blacklist.
    """
    __tablename__ = "screentimes"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    
    # Khóa ngoại liên kết với bảng users (kiểu Integer khớp với user.py)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    
    # Ngày ghi nhận dữ liệu
    record_date = Column(Date, default=date.today, nullable=False, index=True)
    
    # Tầng 1: Tổng quan (Dashboard)
    total_hours = Column(Float, default=0.0, nullable=False)
    
    # Tầng 2: Focus (Blacklist - Các app gây xao nhãng)
    blacklist_hours = Column(Float, default=0.0, nullable=False)
    
    # Timestamp tự động
    created_at = Column(DateTime, default=func.now(), nullable=False)
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now(), nullable=False)

    # Đảm bảo mỗi user chỉ có 1 bản ghi duy nhất cho mỗi ngày
    __table_args__ = (
        UniqueConstraint('user_id', 'record_date', name='_user_date_uc'),
    )

    owner = relationship("User", back_populates="screentimes")
