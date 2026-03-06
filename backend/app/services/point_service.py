from sqlalchemy.orm import Session
from app.models.user import User


def add_points_from_minutes(
    db: Session,
    user_id: int,
    minutes: int
):

    points = minutes // 100

    user = db.query(User).filter(
        User.id == user_id
    ).first()

    user.points += points

    db.commit()

    return user.points