from pydantic_settings import BaseSettings
from typing import List


class Settings(BaseSettings):
    PROJECT_NAME: str = "Screen2Green"
    API_V1_STR: str = "/api/v1"
    BACKEND_CORS_ORIGINS: List[str] = ["http://localhost:3000", "http://localhost:8080"]

    # Database
    DATABASE_URL: str = "mysql+pymysql://screenuser:screenpass123@localhost:3306/screen2green"

    # Firebase
    FIREBASE_CREDENTIALS: str = "/app/firebase_credentials.json"
    FIREBASE_PROJECT_ID: str = "screen2green-tuankietbuv"

    #JWT
    SECRET_KEY: str = "admin123"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    ENVIRONMENT: str = "development"
    REFRESH_TOKEN_EXPIRE_MINUTES: int = 7

    #TensorFlow
    TENSORFLOW_MODEL_PATH: str = "/app/models/screen_usage_model.tflite"

    #NGO
    NGO_API_URL: str = "https://api.nogoproject.org"
    NGO_API_KEY: str = "1234567890"

    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
