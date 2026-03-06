from sqlalchemy.orm import Session
from app.models.user import User

def calculate_membership(points:int):
    if points >= 500:
        return "diamond"
    elif points >=100:
        return "gold"
    else:
        return "silver"

def update_membership(
        db: Session,
        user_id: int
):
    user = db.query(User).filter(
        User.id == user_id
    ).first()

    membership = calculate_membership(
        user.points
    )

    user.membership = membership

    db.commit()
    
    return membership