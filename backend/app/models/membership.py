from sqlalchemy import Column, Interger, ForeignKey, String, Datetime, func
from sqlalchemy.orm import relationship

from app.db.base import Base
from app.models.base import TimestampMixin
from app.models.screentime import Screentime
from app. models.user import User, points

class membership(Base, TimestampMixin):
    __tablename__ = "membership"

    id = Column(Interger, primary_key=True, index=True, autoincrement=True)
    user_id = Column(Interger, ForeignKey("user.id"), nullale = False)
    