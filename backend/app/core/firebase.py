import os
import firebase_admin
from firebase_admin import credentials, auth

from app.core.config import settings


def initialize_firebase():
    """Initialize Firebase Admin SDK. Safe to call multiple times."""
    if firebase_admin._apps:
        return
    cred_path = os.getenv("FIREBASE_CREDENTIALS", settings.FIREBASE_CREDENTIALS)
    cred = credentials.Certificate(cred_path)
    firebase_admin.initialize_app(cred)


def verify_id_token(token: str) -> dict:
    """Verify Firebase ID token. Returns decoded claims or raises."""
    return auth.verify_id_token(token)
