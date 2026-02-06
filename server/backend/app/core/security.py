"""
Security utilities: JWT, password hashing, etc.
"""

from datetime import datetime, timedelta
from typing import Optional
from jose import JWTError, jwt
from passlib.context import CryptContext
from app.core.config import settings
import hashlib

# Password hashing with bcrypt
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def _prepare_password(password: str) -> str:
    """Prepare password for bcrypt by ensuring it's under 72 bytes"""
    password_bytes = password.encode('utf-8')
    if len(password_bytes) > 72:
        # Hash long passwords with SHA256 first to ensure they fit in 72 bytes
        return hashlib.sha256(password_bytes).hexdigest()
    return password

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a password against a hash"""
    try:
        prepared_password = _prepare_password(plain_password)
        return pwd_context.verify(prepared_password, hashed_password)
    except Exception as e:
        # If password is still too long, try with just first 72 chars
        if "72 bytes" in str(e):
            truncated = plain_password[:72]
            return pwd_context.verify(truncated, hashed_password)
        raise

def get_password_hash(password: str) -> str:
    """Hash a password"""
    try:
        prepared_password = _prepare_password(password)
        return pwd_context.hash(prepared_password)
    except Exception as e:
        # If password is still too long, try with just first 72 chars
        if "72 bytes" in str(e):
            truncated = password[:72]
            return pwd_context.hash(truncated)
        raise

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """Create JWT access token"""
    to_encode = data.copy()
    
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
    
    return encoded_jwt

def decode_access_token(token: str) -> Optional[dict]:
    """Decode JWT access token"""
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        return payload
    except JWTError:
        return None
