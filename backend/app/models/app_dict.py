# File: app/models/app_dict.py
from sqlalchemy import Column, String, DateTime
from sqlalchemy.sql import func
from app.db.base import Base

class AppDictionary(Base):
    __tablename__ = "app_dictionary"

    # VD: com.facebook.katana
    package_name = Column(String(255), primary_key=True, index=True)
    
    # VD: Facebook
    app_name = Column(String(255), nullable=True)
    
    # VD: SOCIAL (Từ Google Play)
    play_category = Column(String(100), nullable=True)
    
    # VD: blacklist, productivity, neutral (Phân loại của hệ thống bạn)
    internal_category = Column(String(50), nullable=False)
    
    created_at = Column(DateTime, default=func.now(), nullable=False)