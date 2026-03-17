import math

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
    
    # Quy đổi môi trường
    POINTS_PER_TREE = 500          # Cứ 500 điểm = 1 cây xanh
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
    def calculate_environmental_impact(cls, total_points: int):
        """
        Quy đổi tổng điểm tích lũy của user ra Cây xanh và CO2.
        Trả về tuple: (total_trees, co2_offset)
        """
        total_trees = total_points // cls.POINTS_PER_TREE
        co2_offset = total_trees * cls.CO2_PER_TREE_KG
        
        return total_trees, round(co2_offset, 2)

    @classmethod
    def calculate_progress_bars(cls, total_hours: float, blacklist_hours: float):
        """
        Tính toán % để Flutter vẽ thanh Progress Bar.
        Ví dụ: dùng 1h / target 1.5h => trả về 0.66 (66%)
        """
        total_progress = total_hours / cls.TARGET_TOTAL_HOURS
        blacklist_progress = blacklist_hours / cls.TARGET_BLACKLIST_HOURS
        
        return round(total_progress, 3), round(blacklist_progress, 3)