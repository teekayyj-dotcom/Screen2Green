import math
from sqlalchemy.orm import Session

from app.models.user import User
from app.models.items import Tree
from app.services.membership_service import calculate_membership


class PointService:
    """
    Service xử lý logic Gamification và tính toán điểm thưởng
    cho dự án Screen2Green dựa trên mô hình Hybrid.
    """

    # ==========================================
    # CẤU HÌNH MỤC TIÊU (Có thể chuyển vào Database sau này)
    # ==========================================
    TARGET_TOTAL_HOURS = 5.0       # Mức trần tổng thời gian (Tầng 1)
    TARGET_BLACKLIST_HOURS = 1.5   # Mức trần app gây xao nhãng (Tầng 2)

    MAX_DAILY_POINTS = 100         # Tổng điểm tối đa 1 ngày có thể đạt được
    WEIGHT_BLACKLIST = 0.8         # 80% trọng số cho Blacklist
    WEIGHT_TOTAL = 0.2             # 20% trọng số cho Tổng thời gian

    CO2_PER_TREE_KG = 12.0         # 1 cây = 12kg CO2

    @classmethod
    def calculate_daily_points(cls, total_hours: float, blacklist_hours: float) -> int:
        """
        Tính toán điểm Xanh (Green Points) nhận được trong ngày.
        Áp dụng công thức thưởng cho việc giữ thời gian dưới mức Target.
        """
        # 1. Tính điểm Blacklist (Tối đa 80 điểm)
        # Nếu dùng nhiều hơn Target -> 0 điểm. Nếu dùng 0h -> 80 điểm.
        if blacklist_hours >= cls.TARGET_BLACKLIST_HOURS:
            blacklist_points = 0
        else:
            ratio = 1 - (blacklist_hours / cls.TARGET_BLACKLIST_HOURS)
            blacklist_points = (cls.MAX_DAILY_POINTS * cls.WEIGHT_BLACKLIST) * ratio

        # 2. Tính điểm Tổng thời gian (Tối đa 20 điểm)
        if total_hours >= cls.TARGET_TOTAL_HOURS:
            total_points = 0
        else:
            ratio = 1 - (total_hours / cls.TARGET_TOTAL_HOURS)
            total_points = (cls.MAX_DAILY_POINTS * cls.WEIGHT_TOTAL) * ratio

        # Tổng hợp điểm và làm tròn
        daily_points = math.floor(blacklist_points + total_points)
        return daily_points

    @classmethod
    def calculate_environmental_impact(cls, total_trees: int) -> float:
        """
        Tính tổng CO2 offset dựa vào số cây user đã trồng.
        Trả về: co2_offset (kg)
        """
        co2_offset = total_trees * cls.CO2_PER_TREE_KG
        return round(co2_offset, 2)

    @classmethod
    def calculate_progress_bars(cls, total_hours: float, blacklist_hours: float):
        """
        Tính toán % để Flutter vẽ thanh Progress Bar.
        Ví dụ: dùng 1h / target 1.5h => trả về 0.66 (66%)
        """
        total_progress = total_hours / cls.TARGET_TOTAL_HOURS
        blacklist_progress = blacklist_hours / cls.TARGET_BLACKLIST_HOURS

        return round(total_progress, 3), round(blacklist_progress, 3)


def redeem_trees(db: Session, user_id: int, points_to_spend: int) -> dict:
    """
    Đổi GreenPoints → Cây xanh theo tỉ lệ của level hiện tại của user.

    Logic:
    1. Lấy level hiện tại dựa vào tree_planted
    2. Tính số cây có thể đổi: trees = points_to_spend // points_per_tree
    3. Trừ điểm thực tế, cộng cây, cập nhật membership, ghi lịch sử

    Returns:
        dict: trees_redeemed, points_spent, points_remaining, membership info, co2_offset

    Raises:
        ValueError: nếu không đủ điểm hoặc points_to_spend < points_per_tree
    """
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise ValueError(f"User {user_id} not found")

    # Lấy tỉ lệ đổi theo level hiện tại
    current_level = calculate_membership(user.tree_planted)
    points_per_tree = current_level["points_per_tree"]

    # Kiểm tra đủ điểm để đổi ít nhất 1 cây
    if points_to_spend < points_per_tree:
        raise ValueError(
            f"Cần ít nhất {points_per_tree} điểm để đổi 1 cây "
            f"(level hiện tại: {current_level['name']}). "
            f"Bạn muốn dùng {points_to_spend} điểm."
        )

    if user.points < points_to_spend:
        raise ValueError(
            f"Không đủ điểm. Bạn có {user.points} điểm, "
            f"muốn dùng {points_to_spend} điểm."
        )

    # Tính số cây đổi được và điểm thực tế bị trừ
    trees_redeemed = points_to_spend // points_per_tree
    actual_points_spent = trees_redeemed * points_per_tree

    # Cập nhật user
    user.points -= actual_points_spent
    user.tree_planted += trees_redeemed

    # Cập nhật membership_level sau khi cây tăng
    new_level = calculate_membership(user.tree_planted)
    user.membership_level = new_level["name"]

    # Ghi lịch sử giao dịch vào bảng trees
    transaction = Tree(
        user_id=user_id,
        points_spent=actual_points_spent,
        trees_redeemed=trees_redeemed,
        points_per_tree=points_per_tree,
        level_at_redemption=current_level["name"],
    )
    db.add(transaction)
    db.commit()
    db.refresh(user)

    co2_offset = PointService.calculate_environmental_impact(user.tree_planted)

    return {
        "trees_redeemed":     trees_redeemed,
        "points_spent":       actual_points_spent,
        "points_remaining":   user.points,
        "tree_planted_total": user.tree_planted,
        "membership_level":   new_level["name"],
        "points_per_tree":    new_level["points_per_tree"],
        "co2_offset_kg":      co2_offset,
    }