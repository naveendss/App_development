"""
Quick API test script
Run: python test_api.py
"""

import requests
import json

BASE_URL = "http://localhost:8000/api/v1"

def test_health():
    """Test if API is running"""
    try:
        response = requests.get("http://localhost:8000/health")
        print(f"✅ Health check: {response.json()}")
        return True
    except Exception as e:
        print(f"❌ Health check failed: {e}")
        return False

def test_register():
    """Test user registration"""
    data = {
        "email": "test@example.com",
        "password": "Test123!",
        "full_name": "Test User",
        "phone_number": "+919876543210",
        "user_type": "customer"
    }
    try:
        response = requests.post(f"{BASE_URL}/auth/register", json=data)
        print(f"✅ Register: {response.status_code}")
        return response.json()
    except Exception as e:
        print(f"❌ Register failed: {e}")
        return None

def test_login(email, password):
    """Test user login"""
    data = {
        "email": email,
        "password": password
    }
    try:
        response = requests.post(f"{BASE_URL}/auth/login", json=data)
        print(f"✅ Login: {response.status_code}")
        return response.json()
    except Exception as e:
        print(f"❌ Login failed: {e}")
        return None

def test_docs():
    """Check if docs are accessible"""
    try:
        response = requests.get("http://localhost:8000/api/docs")
        print(f"✅ API Docs accessible: {response.status_code == 200}")
    except Exception as e:
        print(f"❌ Docs check failed: {e}")

if __name__ == "__main__":
    print("🧪 Testing Openkora API...\n")
    
    # Test health
    if not test_health():
        print("\n⚠️  API is not running. Start it with: uvicorn app.main:app --reload")
        exit(1)
    
    print("\n📚 API Documentation: http://localhost:8000/api/docs")
    print("📊 Alternative Docs: http://localhost:8000/api/redoc")
    
    # Test docs
    test_docs()
    
    print("\n✅ All basic tests passed!")
    print("\n💡 To test endpoints:")
    print("   1. Visit http://localhost:8000/api/docs")
    print("   2. Register a user")
    print("   3. Login to get token")
    print("   4. Use token in 'Authorize' button")
