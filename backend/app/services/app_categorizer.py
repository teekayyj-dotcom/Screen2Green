# File: app/services/app_categorizer.py
from sqlalchemy.orm import Session
from google_play_scraper import app as scrape_app
from app.models.app_dict import AppDictionary
from typing import List
import logging

logger = logging.getLogger(__name__)

class AppCategorizerService:
    # Từ điển dịch thể loại từ Google Play sang chuẩn của Screen2Green
    CATEGORY_MAPPING = {
        # Nhóm Blacklist (Gây xao nhãng)
        "GAME": "blacklist",
        "SOCIAL": "blacklist",
        "ENTERTAINMENT": "blacklist",
        "VIDEO_PLAYERS": "blacklist",
        "DATING": "blacklist",
        "COMICS": "blacklist",
        
        # Nhóm Productivity (Hữu ích)
        "PRODUCTIVITY": "productivity",
        "EDUCATION": "productivity",
        "BUSINESS": "productivity",
        "FINANCE": "productivity",
        "HEALTH_AND_FITNESS": "productivity",
        "BOOKS_AND_REFERENCE": "productivity",
        
        # Còn lại sẽ mặc định là "neutral" (Trung lập)
    }

    @classmethod
    def process_app_usages(cls, db: Session, apps_data: List) -> float:
        """
        Nhận danh sách app, quét qua DB Cache hoặc Google Play.
        Trả về con số blacklist_hours chuẩn xác nhất do Backend tự tính.
        """
        calculated_blacklist_hours = 0.0

        for item in apps_data:
            package = item.package_name
            duration_minutes = item.minutes
            duration = duration_minutes / 60.0
            
            if duration <= 0:
                continue

            # 1. Tìm trong Cache Database trước (Tốc độ ánh sáng)
            app_record = db.query(AppDictionary).filter(AppDictionary.package_name == package).first()
            
            if not app_record:
                # 2. Nếu chưa có, tiến hành cào dữ liệu từ Google Play
                internal_cat = "neutral"
                app_name = "Unknown App"
                play_cat = "UNKNOWN"
                
                try:
                    # Gọi API của thư viện scraper
                    result = scrape_app(package, lang='en', country='us')
                    app_name = result.get('title', package)
                    play_cat = result.get('genreId', 'UNKNOWN').upper()
                    
                    # Mapping thể loại
                    internal_cat = cls.CATEGORY_MAPPING.get(play_cat, "neutral")
                    
                except Exception as e:
                    # Lỗi thường do App iOS (Apple Store), app nội bộ, hoặc không có kết nối mạng
                    logger.warning(f"Không thể cào dữ liệu cho package {package}: {e}")

                # 3. Lưu kết quả vào Database làm Cache cho những lần sau
                app_record = AppDictionary(
                    package_name=package,
                    app_name=app_name,
                    play_category=play_cat,
                    internal_category=internal_cat
                )
                db.add(app_record)
                db.commit()
                db.refresh(app_record)

            # 4. Nếu app này là blacklist, cộng dồn thời gian
            if app_record.internal_category == "blacklist":
                calculated_blacklist_hours += duration

        return calculated_blacklist_hours
