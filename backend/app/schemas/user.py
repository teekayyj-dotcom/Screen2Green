from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class UserBase(BaseModel):
    username: str
    email: str
    full_name: Optional[str] = None


class UserCreate(UserBase):
    firebase_uid: Optional[str] = None
    password: Optional[str] = None  # Only if not using Firebase


class UserSyncRequest(BaseModel):
    username: Optional[str] = None
    email: Optional[str] = None
    full_name: Optional[str] = None


class UserUpdate(BaseModel):
    full_name: Optional[str] = None
    username: Optional[str] = None
    email: Optional[str] = None

class UserResponse(UserBase):
    id: int
    firebase_uid: Optional[str] = None
    points: int = 0
    membership_level: str = "member"
    created_at: datetime

    class Config:
        from_attributes = True


class UserInDB(UserResponse):
    """Full user as stored in DB (e.g. for internal use)."""
    updated_at: datetime
