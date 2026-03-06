from fastapi import APIRouter, Depends

from app.api.deps import get_current_user

router = APIRouter()


@router.get("/me")
def get_me(current_user: dict = Depends(get_current_user)):
    """Return current user info from verified Firebase token."""
    return {
        "uid": current_user["uid"],
        "email": current_user.get("email"),
        "name": current_user.get("name"),
        "picture": current_user.get("picture"),
    }


@router.post("/verify")
def verify(current_user: dict = Depends(get_current_user)):
    """Verify token is valid. Returns user info if valid."""
    return {"valid": True, "uid": current_user["uid"]}
