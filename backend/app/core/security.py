import firebase_admin
from firebase_admin import auth, credentials
from fastapi import HTTPException, status, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from app.core.config import settings

# Khởi tạo Firebase Admin (Nên để trong main.py hoặc một file init riêng)
# cred = credentials.Certificate("path/to/your/firebase_key.json")
# firebase_admin.initialize_app(cred)

security = HTTPBearer()

async def get_current_user(res: HTTPAuthorizationCredentials = Depends(security)):
    """
    Hàm này sẽ chặn các request, lấy Token từ Header, 
    verify với Firebase và trả về thông tin User.
    """
    token = res.credentials
    try:
        # Xác thực token trực tiếp với Google Firebase Server
        decoded_token = auth.verify_id_token(token)
        
        # Nếu hợp lệ, bạn sẽ nhận được thông tin như uid, email...
        user_uid = decoded_token.get("uid")
        return decoded_token
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid or expired token: {str(e)}",
            headers={"WWW-Authenticate": "Bearer"},
        )