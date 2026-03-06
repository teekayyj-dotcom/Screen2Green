from sqlalchemy import Column, Integer, String

from app.db.base import Base


class Item(Base):
    """Base class for Item model to share common attributes."""
    __tablename__ = 'items'
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), unique=True, index=True, nullable=False)
    description = Column(String(1024), nullable=True)
    