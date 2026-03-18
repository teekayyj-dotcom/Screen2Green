from pydantic import BaseModel, Field
from typing import List

# ==========================================
# 1. DỮ LIỆU FLUTTER GỬI LÊN (REQUEST)
# ==========================================

# Schema for each app
class AppUsageItem(BaseModel):
    package_name: str = Field(..., description=" Vi du: com.facebook")
    minutes: int = Field(..., description="Screentime theo phut", ge=0)


class ScreenTimeSyncRequest(BaseModel):
    total_hours: float = Field(
        ..., 
        description="Tổng thời gian sáng màn hình (Tầng 1)",
        ge=0.0
    )
    apps: List[AppUsageItem] =  Field(default=[], description="App list for backend deep sorting")


# ==========================================
# 2. DỮ LIỆU FASTAPI TRẢ VỀ (RESPONSE)
# ==========================================
class ScreenTimeDashboardResponse(BaseModel):
    """
    Schema trả về cho Flutter để cập nhật UI Dashboard & Gamification.
    """
    # Các chỉ số thời gian
    total_hours: float
    blacklist_hours: float
    
    # Tiến độ (Progress Bar) - Trọng số sẽ ưu tiên hiển thị blacklist_progress
    hours_progress: float
    blacklist_progress: float
    
    # Chỉ số cây xanh (Tầng 3 - Gamification)
    total_trees: int
    trees_this_month: int
    
    # Chỉ số bảo vệ môi trường
    co2_offset: float
    
    # Điểm thưởng hiện tại
    green_points: int
    
    # Dữ liệu vẽ biểu đồ (Chart)
    today_usage: List[float]           # Dành cho chart tổng quan
    today_blacklist_usage: List[float] # Dành cho chart Focus (quan trọng hơn)

    # class Config:
    #     json_schema_extra = {
    #         "example": {
    #             "total_hours": 6.5,
    #             "blacklist_hours": 1.2,
    #             "total_progress": 1.3,      # Vượt target 5h (6.5/5.0)
    #             "blacklist_progress": 0.8,  # Đạt target 1.5h (1.2/1.5) -> Thưởng điểm
    #             "total_trees": 15,
    #             "trees_this_month": 4,
    #             "co2_offset": 180.0,
    #             "green_points": 120,
    #             "today_usage": [1.0, 2.5, 4.0, 5.2, 6.5],
    #             "today_blacklist_usage": [0.2, 0.5, 0.8, 1.0, 1.2]
    #         }
    #     }
