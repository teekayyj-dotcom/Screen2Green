from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps import get_db
from app.services.membership_service import update_membership
from app.schemas.membership import MembershipResponse
from app.models.user import User

router = APIRouter()

@router.get("/{user_id}", status_code= status.HTTP_200_OK, response_model=MembershipResponse)

async def get_membership(
    user_id: int,
    db: Session = Depends(get_db)
):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"User with id {user_id} not found"
        )
    
    membership = update_membership(db, user.id)
    return {"membership": membership, 
            "points": user.points
            }