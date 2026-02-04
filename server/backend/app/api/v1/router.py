"""
Main API router - combines all endpoint routers
"""

from fastapi import APIRouter
from app.api.v1.endpoints import (
    auth, users, gyms, equipment, bookings, payments, 
    community, notifications, memberships, attendance, 
    reviews, saved_gyms
)

api_router = APIRouter()

# Include all endpoint routers
api_router.include_router(auth.router, prefix="/auth", tags=["Authentication"])
api_router.include_router(users.router, prefix="/users", tags=["Users"])
api_router.include_router(gyms.router, prefix="/gyms", tags=["Gyms"])
api_router.include_router(equipment.router, prefix="/equipment", tags=["Equipment"])
api_router.include_router(bookings.router, prefix="/bookings", tags=["Bookings"])
api_router.include_router(payments.router, prefix="/payments", tags=["Payments"])
api_router.include_router(community.router, prefix="/community", tags=["Community"])
api_router.include_router(notifications.router, prefix="/notifications", tags=["Notifications"])
api_router.include_router(memberships.router, prefix="/memberships", tags=["Memberships"])
api_router.include_router(attendance.router, prefix="/attendance", tags=["Attendance"])
api_router.include_router(reviews.router, prefix="/reviews", tags=["Reviews"])
api_router.include_router(saved_gyms.router, prefix="/saved-gyms", tags=["Saved Gyms"])
