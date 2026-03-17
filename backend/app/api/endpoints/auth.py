from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.models.user import User as UserModel
from app.schemas.user import UserResponse, UserSyncRequest

router = APIRouter()

@router.get("/me")
async def get_me(current_user: dict = Depends(get_current_user)):
    """
    Trả về thông tin user từ Firebase Token.
    Đây là nơi Flutter gọi để kiểm tra xem mình là ai sau khi login.
    """
    return {
        "uid": current_user.get("uid"),
        "email": current_user.get("email"),
        "name": current_user.get("name"),
        "picture": current_user.get("picture"),
        "auth_time": current_user.get("auth_time") # Thời điểm login
    }

def _build_username_seed(current_user: dict, payload: UserSyncRequest | None) -> str:
    if payload and payload.username:
        return payload.username.strip()

    if current_user.get("name"):
        return str(current_user["name"]).strip().replace(" ", "_").lower()

    email = current_user.get("email") or (payload.email if payload else None)
    if email:
        return str(email).split("@")[0].strip().lower()

    return f"user_{str(current_user['uid'])[:8].lower()}"


def _generate_unique_username(
    db: Session,
    username_seed: str,
    current_uid: str,
) -> str:
    base_username = username_seed or f"user_{current_uid[:8].lower()}"
    candidate = base_username
    suffix = 1

    while True:
        existing_user = db.query(UserModel).filter(UserModel.username == candidate).first()
        if not existing_user or existing_user.firebase_uid == current_uid:
            return candidate

        candidate = f"{base_username}_{suffix}"
        suffix += 1


@router.post("/sync-user", response_model=UserResponse, status_code=status.HTTP_200_OK)
async def sync_user_to_db(
    payload: UserSyncRequest | None = None,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Upsert user từ Firebase token vào DB nội bộ.
    """
    uid = current_user.get("uid")
    email = current_user.get("email") or (payload.email if payload else None)

    if not uid:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Firebase token is missing uid",
        )

    if not email:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email is required to sync user",
        )

    full_name = (
        (payload.full_name if payload and payload.full_name else None)
        or current_user.get("name")
        or email.split("@")[0]
    )
    username_seed = _build_username_seed(current_user, payload)

    db_user = db.query(UserModel).filter(UserModel.firebase_uid == uid).first()
    if not db_user:
        db_user = db.query(UserModel).filter(UserModel.email == email).first()

    username = _generate_unique_username(db, username_seed, uid)

    if db_user:
        db_user.firebase_uid = uid
        db_user.email = email
        db_user.full_name = full_name
        if not db_user.username:
            db_user.username = username
    else:
        db_user = UserModel(
            firebase_uid=uid,
            email=email,
            full_name=full_name,
            username=username,
        )
        db.add(db_user)

    db.commit()
    db.refresh(db_user)

    return db_user
