"""
Alternative: Use Supabase Client instead of direct PostgreSQL connection
This uses Supabase's REST API which is more reliable
"""

from supabase import create_client, Client

# Get these from: Supabase Dashboard > Settings > API
SUPABASE_URL = "https://tjycgeecmltheaorcci.supabase.co"
SUPABASE_KEY = "YOUR_ANON_KEY_HERE"  # Replace with your anon/public key

try:
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
    
    # Test connection by querying a system table
    response = supabase.table('_migrations').select("*").limit(1).execute()
    
    print("✅ Supabase client connected successfully!")
    print(f"📊 API URL: {SUPABASE_URL}")
    
except Exception as e:
    print(f"❌ Connection failed: {e}")
    print("\nTo fix:")
    print("1. Go to Supabase Dashboard > Settings > API")
    print("2. Copy your 'anon' or 'public' key")
    print("3. Update SUPABASE_KEY in this script")
