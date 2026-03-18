from sqlalchemy.orm import Session
from app.models.user import User

# ==========================================
# CẤU HÌNH LOYALTY LEVELS (module-level constant)
# Sắp xếp từ CAO → THẤP để tìm level cao nhất user đạt được
# ==========================================
LEVELS = [
    {"name": "The Forest",  "min_trees": 100, "points_per_tree": 150},
    {"name": "The Ancient", "min_trees": 50,  "points_per_tree": 170},
    {"name": "The Canopy",  "min_trees": 25,  "points_per_tree": 180},
    {"name": "The Sprout",  "min_trees": 10,  "points_per_tree": 190},
    {"name": "The Seed",    "min_trees": 0,   "points_per_tree": 200},
]


class MembershipService:
    """
    Service xử lý loyalty system và tính toán membership level
    dựa trên số cây user đã trồng (tree_planted).
    """
    LEVELS = LEVELS  # Expose để có thể truy cập qua MembershipService.LEVELS


def calculate_membership(trees_planted: int) -> dict:
    """
    Tính membership level dựa vào số cây đã trồng.
    Duyệt từ level CAO → THẤP, trả về level cao nhất user đạt được.
    Luôn trả về ít nhất "The Seed" (min_trees=0).
    """
    for level in LEVELS:
        if trees_planted >= level["min_trees"]:
            return level
    return LEVELS[-1]  # fallback: The Seed


def get_points_per_tree(trees_planted: int) -> int:
    """
    Trả về tỉ lệ điểm cần để đổi 1 cây dựa trên level hiện tại.
    """
    level = calculate_membership(trees_planted)
    return level["points_per_tree"]


def update_membership(db: Session, user_id: int) -> dict:
    """
    Cập nhật membership_level của user trong DB dựa vào tree_planted.
    Trả về dict chứa thông tin level hiện tại.
    """
    user = db.query(User).filter(User.id == user_id).first()

    level = calculate_membership(user.tree_planted)

    user.membership_level = level["name"]
    db.commit()

    return {
        "membership_level": level["name"],
        "points_per_tree":  level["points_per_tree"],
        "min_trees":        level["min_trees"],
        "tree_planted":     user.tree_planted,
        "points":           user.points,
    }