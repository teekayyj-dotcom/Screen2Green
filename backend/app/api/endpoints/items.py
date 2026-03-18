from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps import get_db
from app.models.user import User
from app.models.items import Tree
from app.services.point_service import PointService, redeem_trees
from app.services.membership_service import calculate_membership
from app.schemas.item import TreeRedeemRequest, TreeRedeemResponse, TreeRateResponse, TreeHistoryItem

router = APIRouter()


@router.get("/rate/{user_id}", response_model=TreeRateResponse, status_code=status.HTTP_200_OK)
async def get_redeem_rate(
    user_id: int,
    db: Session = Depends(get_db)
):
    """
    Xem tỉ lệ đổi điểm → cây hiện tại của user.
    Tỉ lệ phụ thuộc vào membership level (dựa vào tree_planted).
    """
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"User {user_id} not found"
        )

    level = calculate_membership(user.tree_planted)
    co2_offset = PointService.calculate_environmental_impact(user.tree_planted)

    return {
        "membership_level": level["name"],
        "points_per_tree":  level["points_per_tree"],
        "tree_planted":     user.tree_planted,
        "points":           user.points,
        "co2_offset_kg":    co2_offset,
    }


@router.post("/redeem/{user_id}", response_model=TreeRedeemResponse, status_code=status.HTTP_200_OK)
async def redeem_points_for_trees(
    user_id: int,
    body: TreeRedeemRequest,
    db: Session = Depends(get_db)
):
    """
    Đổi GreenPoints → Cây xanh theo tỉ lệ của level hiện tại.

    - Level càng cao → cần ít điểm hơn để đổi 1 cây
    - Điểm dư (không đủ để đổi thêm 1 cây) sẽ được giữ lại
    - Membership tự động cập nhật nếu đủ điều kiện lên level mới
    """
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"User {user_id} not found"
        )

    try:
        result = redeem_trees(db, user_id, body.points_to_spend)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

    return result


@router.get("/history/{user_id}", response_model=list[TreeHistoryItem], status_code=status.HTTP_200_OK)
async def get_tree_history(
    user_id: int,
    db: Session = Depends(get_db)
):
    """
    Lấy lịch sử tất cả các giao dịch đổi cây của user.
    """
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"User {user_id} not found"
        )

    transactions = db.query(Tree).filter(Tree.user_id == user_id).order_by(Tree.id.desc()).all()
    return transactions
