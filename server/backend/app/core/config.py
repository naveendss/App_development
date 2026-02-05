"""
Application configuration
"""

from pydantic_settings import BaseSettings
from typing import Optional

class Settings(BaseSettings):
    # App
    APP_NAME: str = "Openkora"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False
    
    # Database - with fallback
    DATABASE_URL: str = "postgresql://postgres.tjycgeecomltheaorcci:Openkora2026@aws-1-ap-south-1.pooler.supabase.com:5432/postgres"
    
    # Supabase - with fallback
    SUPABASE_URL: str = "https://tjycgeecomltheaorcci.supabase.co"
    SUPABASE_KEY: str = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRqeWNnZWVjb21sdGhlYW9yY2NpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAxMTY1MjUsImV4cCI6MjA4NTY5MjUyNX0.tfgty8bNrNUQQOzY-Fd_OMips08jmDwN04guCOmpSvo"
    SUPABASE_SERVICE_KEY: Optional[str] = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRqeWNnZWVjb21sdGhlYW9yY2NpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MDExNjUyNSwiZXhwIjoyMDg1NjkyNTI1fQ.b8IGqfGPmt8EQd7asmKsOQAY69a-sVVGBaKatrIG8is"
    
    # JWT - with fallback
    SECRET_KEY: str = "7f8a9b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 10080  # 7 days
    
    # Currency
    CURRENCY: str = "INR"
    CURRENCY_SYMBOL: str = "₹"
    
    # File Upload
    MAX_FILE_SIZE: int = 5242880  # 5MB
    ALLOWED_EXTENSIONS: str = "jpg,jpeg,png,webp"
    
    class Config:
        env_file = ".env"
        case_sensitive = True

settings = Settings()
