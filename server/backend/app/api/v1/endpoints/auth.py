"""
Authentication endpoints
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.security import create_access_token, get_password_hash, verify_password
from app.core.utils import get_avatar_url
from app.schemas.auth import LoginRequest, LoginResponse, RegisterRequest, RegisterResponse
from app.models.user import User
from app.models.customer_profile import CustomerProfile
from datetime import timedelta

router = APIRouter()

@router.post("/register", response_model=RegisterResponse, status_code=status.HTTP_201_CREATED)
async def register(request: RegisterRequest, db: Session = Depends(get_db)):
    """
    Register a new user with email and password
    """
    # Check if user already exists by email
    existing_user = db.query(User).filter(User.email == request.email).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User with this email already exists"
        )
    
    # Check phone if provided
    if request.phone:
        existing_phone = db.query(User).filter(User.phone == request.phone).first()
        if existing_phone:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User with this phone number already exists"
            )
    
    # Hash password
    password_hash = get_password_hash(request.password)
    
    # Create new user
    new_user = User(
        email=request.email,
        password_hash=password_hash,
        phone=request.phone,
        full_name=request.full_name,
        user_type=request.user_type,
        profile_image_url=get_avatar_url(request.email, request.full_name)
    )
    
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    # Create customer profile if user is customer
    if request.user_type == "customer":
        customer_profile = CustomerProfile(user_id=new_user.id)
        db.add(customer_profile)
        db.commit()
    
    # Generate access token
    access_token = create_access_token(
        data={"sub": str(new_user.id), "user_type": new_user.user_type}
    )
    
    return {
        "access_token": access_token,
        "user_id": str(new_user.id),
        "user_type": new_user.user_type,
        "full_name": new_user.full_name,
        "profile_image_url": new_user.profile_image_url,
        "token_type": "bearer"
    }

@router.post("/login", response_model=LoginResponse)
async def login(request: LoginRequest, db: Session = Depends(get_db)):
    """
    Login with email and password
    """
    try:
        # Find user by email
        user = db.query(User).filter(User.email == request.email).first()
        
        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password"
            )
        
        # Verify password
        if not user.password_hash or not verify_password(request.password, user.password_hash):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password"
            )
        
        # Check user type if specified
        if request.user_type and user.user_type != request.user_type:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"This account is not a {request.user_type} account"
            )
        
        # Generate access token
        access_token = create_access_token(
            data={"sub": str(user.id), "user_type": user.user_type}
        )
        
        return LoginResponse(
            access_token=access_token,
            user_id=str(user.id),
            user_type=user.user_type,
            full_name=user.full_name,
            profile_image_url=user.profile_image_url
        )
    except HTTPException:
        raise
    except Exception as e:
        print(f"Login error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Login failed: {str(e)}"
        )

@router.post("/verify-token")
async def verify_token(db: Session = Depends(get_db)):
    """
    Verify if token is valid (protected route)
    """
    return {"message": "Token is valid"}
