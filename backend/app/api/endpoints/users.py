from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from typing import Optional

from app.api.deps import get_db
from app.models.user import User as UserModel
from app.schemas.user import UserCreate

router = APIRouter()


@router.post("/users", status_code=status.HTTP_201_CREATED, tags=["users"])
async def create_user(user: UserCreate, db: Session = Depends(get_db)):
    db_user = UserModel(username=user.username, email=user.email, full_name=user.full_name)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

@router.get("/{user_id}", status_code=status.HTTP_200_OK, tags=["users"])
async def get_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(UserModel).filter(UserModel.id == user_id).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    return user

@router.get("/", status_code=status.HTTP_200_OK, tags=["users"])
async def list_users(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    users = db.query(UserModel).offset(skip).limit(limit).all()
    return users

@router.delete("/{user_id}", status_code=status.HTTP_204_NO_CONTENT, tags=["users"])
async def delete_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(UserModel).filter(UserModel.id == user_id).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    db.delete(user)
    db.commit()
    return None

from app.schemas.user import UserUpdate  # Ensure you have an Update schema

@router.patch("/{user_id}", status_code=status.HTTP_200_OK, tags=["users"])
async def edit_user(
    user_id: int, 
    user_update: Optional[UserUpdate] = None, 
    db: Session = Depends(get_db)
):
    if user_update is None:
        raise HTTPException(status_code=400, detail="JSON body is required")
    # 1. Fetch the existing user from the DB
    db_user = db.query(UserModel).filter(UserModel.id == user_id).first()
    
    if not db_user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, 
            detail="User not found"
        )

    # 2. Extract the update data from the Pydantic model
    # Use .model_dump(exclude_unset=True) if using Pydantic v2
    update_data = user_update.dict(exclude_unset=True)

    # 3. Update the DB model attributes dynamically
    for key, value in update_data.items():
        setattr(db_user, key, value)

    # 4. Commit and refresh
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    
    return db_user
