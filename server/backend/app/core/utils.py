"""
Utility functions
"""

import qrcode
from io import BytesIO
import base64
from typing import Optional
import uuid

def generate_qr_code(data: str) -> str:
    """Generate QR code and return as base64 string"""
    qr = qrcode.QRCode(version=1, box_size=10, border=5)
    qr.add_data(data)
    qr.make(fit=True)
    
    img = qr.make_image(fill_color="black", back_color="white")
    
    buffer = BytesIO()
    img.save(buffer, format='PNG')
    buffer.seek(0)
    
    img_base64 = base64.b64encode(buffer.getvalue()).decode()
    return f"data:image/png;base64,{img_base64}"

def generate_booking_id() -> str:
    """Generate unique booking ID in format OK-XXXXX"""
    random_num = str(uuid.uuid4().int)[:5]
    return f"OK-{random_num}"

def get_avatar_url(user_id: str, name: Optional[str] = None) -> str:
    """Generate fallback avatar URL"""
    if name:
        seed = name.replace(" ", "+")
    else:
        seed = user_id
    return f"https://api.dicebear.com/7.x/avataaars/svg?seed={seed}"

def format_currency(amount: float, currency: str = "INR") -> str:
    """Format amount with currency symbol"""
    symbols = {"INR": "₹", "USD": "$", "EUR": "€"}
    symbol = symbols.get(currency, "₹")
    return f"{symbol}{amount:,.2f}"
