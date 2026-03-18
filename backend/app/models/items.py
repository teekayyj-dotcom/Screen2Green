from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship

from app.db.base import Base
from app.models.base import TimestampMixin


class Tree(Base, TimestampMixin):
    """
    Ghi lại lịch sử mỗi giao dịch đổi GreenPoints → Cây xanh.
    Mỗi lần user bấm 'Redeem', một bản ghi Tree mới được tạo.
    """
    __tablename__ = "trees"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)

    # Liên kết với user thực hiện giao dịch
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    # Chi tiết giao dịch
    points_spent = Column(Integer, nullable=False)           # Số điểm đã dùng
    trees_redeemed = Column(Integer, nullable=False)         # Số cây đổi được
    points_per_tree = Column(Integer, nullable=False)        # Tỉ lệ tại thời điểm đổi
    level_at_redemption = Column(String(50), nullable=False) # Level lúc đổi

    # Quan hệ ngược về User
    owner = relationship("User", back_populates="trees")