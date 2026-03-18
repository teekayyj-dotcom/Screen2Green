from pydantic import BaseModel, Field
from typing import Optional


class TreeRedeemRequest(BaseModel):
    """Request body để đổi GreenPoints lấy cây."""
    points_to_spend: int = Field(..., gt=0, description="Số điểm muốn dùng để đổi cây")


class TreeRedeemResponse(BaseModel):
    """Response sau khi đổi điểm thành công."""
    trees_redeemed:     int
    points_spent:       int
    points_remaining:   int
    tree_planted_total: int
    membership_level:   str
    points_per_tree:    int
    co2_offset_kg:      float


class TreeRateResponse(BaseModel):
    """Tỉ lệ đổi điểm → cây của level hiện tại."""
    membership_level: str
    points_per_tree:  int
    tree_planted:     int
    points:           int
    co2_offset_kg:    float


class TreeHistoryItem(BaseModel):
    """Một giao dịch trong lịch sử đổi cây."""
    id:                   int
    points_spent:         int
    trees_redeemed:       int
    points_per_tree:      int
    level_at_redemption:  str
    created_at:           Optional[str] = None

    class Config:
        from_attributes = True
