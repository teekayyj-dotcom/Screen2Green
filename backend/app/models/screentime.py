from sqlalchemy import Column, Integer, ForeignKey, String, DateTime, func
from sqlalchemy.orm import relationship

from app.db.base import Base
from app.models.base import TimestampMixin


class Screentime(Base, TimestampMixin):

    __tablename__ ="screentime"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable = False)
    minute = Column(Integer, default=0)
    owner = relationship("User", back_populates = "screentimes")
