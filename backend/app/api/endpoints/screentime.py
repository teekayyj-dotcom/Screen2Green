from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import date

# Import từ các module trong hệ thống của bạn
from app.api import deps
from app.core.security import get_current_user
from app.models.user import User
from app.models.screentime import Screentime
from app.schemas.screentime import ScreenTimeSyncRequest, ScreenTimeDashboardResponse
from app.services.point_service import PointService

router = APIRouter()

@router.post("/sync", response_model=ScreenTimeDashboardResponse)
async def sync_screentime(
    request: ScreenTimeSyncRequest,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(deps.get_db)
):
    """
    Endpoint đồng bộ dữ liệu Screen Time từ Flutter.
    Xử lý cập nhật số giờ và trả về các chỉ số Gamification (Mô hình Hybrid).
    """
    # 1. Lấy thông tin User từ Database dựa trên Firebase UID
    firebase_uid = current_user.get("uid")
    user = db.query(User).filter(User.firebase_uid == firebase_uid).first()
    
    if not user:
        raise HTTPException(
            status_code=404, 
            detail="Người dùng chưa được đồng bộ. Hãy gọi /sync-user trước."
        )

    # 2. Tìm hoặc Tạo bản ghi Screentime cho ngày hôm nay (Upsert)
    today = date.today()
    screentime_record = db.query(Screentime).filter(
        Screentime.user_id == user.id,
        Screentime.record_date == today
    ).first()

    if screentime_record:
        # Nếu đã có data hôm nay -> Cập nhật (vì Flutter có thể gọi API nhiều lần/ngày)
        screentime_record.total_hours = request.total_hours
        screentime_record.blacklist_hours = request.blacklist_hours
    else:
        # Nếu chưa có -> Tạo mới
        screentime_record = Screentime(
            user_id=user.id,
            record_date=today,
            total_hours=request.total_hours,
            blacklist_hours=request.blacklist_hours
        )
        db.add(screentime_record)
    
    # Lưu thay đổi vào Database
    db.commit()
    db.refresh(screentime_record)

    # 3. Tính toán Gamification qua PointService
    # Tính phần trăm Progress Bar
    total_progress, blacklist_progress = PointService.calculate_progress_bars(
        request.total_hours, 
        request.blacklist_hours
    )
    
    # Tính điểm đạt được hôm nay
    daily_points = PointService.calculate_daily_points(
        request.total_hours, 
        request.blacklist_hours
    )
    
    # LƯU Ý KỸ THUẬT: Vì API này gọi nhiều lần trong ngày, ta không cộng thẳng daily_points 
    # vào user.points ở đây để tránh bị cộng dồn sai (lỗi lặp điểm).
    # Ta sẽ giả định điểm tổng hiển thị = điểm đã chốt các ngày trước + điểm tạm tính hôm nay.
    display_total_points = user.points + daily_points
    
    # Tính Cây xanh và CO2 từ tổng điểm
    total_trees, co2_offset = PointService.calculate_environmental_impact(display_total_points)

    # 4. Trả kết quả về cho Flutter (Khớp 100% với Schema)
    return ScreenTimeDashboardResponse(
        total_hours=request.total_hours,
        blacklist_hours=request.blacklist_hours,
        total_progress=total_progress,
        blacklist_progress=blacklist_progress,
        total_trees=total_trees,
        trees_this_month=0,  # Có thể nâng cấp logic query DB đếm số cây tháng này sau
        co2_offset=co2_offset,
        green_points=display_total_points,
        # Trả về mảng rỗng hoặc giả lập để chart Flutter không bị lỗi null
        today_usage=[request.total_hours], 
        today_blacklist_usage=[request.blacklist_hours] 
    )