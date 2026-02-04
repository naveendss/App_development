import psycopg2
import os
from dotenv import load_dotenv

load_dotenv()

# Different Supabase connection methods
connections = {
    "1. Session Pooler (IPv4)": "postgresql://postgres.tjycgeecmltheaorcci:Openkora2026@aws-1-ap-south-1.pooler.supabase.com:5432/postgres",
    
    "2. Session Pooler (Transaction Mode)": "postgresql://postgres.tjycgeecmltheaorcci:Openkora2026@aws-1-ap-south-1.pooler.supabase.com:6543/postgres",
    
    "3. Direct Connection": "postgresql://postgres.tjycgeecmltheaorcci:Openkora2026@db.tjycgeecmltheaorcci.supabase.co:5432/postgres",
    
    "4. Direct Connection (Port 6543)": "postgresql://postgres.tjycgeecmltheaorcci:Openkora2026@db.tjycgeecmltheaorcci.supabase.co:6543/postgres",
    
    "5. With SSL Mode": "postgresql://postgres.tjycgeecmltheaorcci:Openkora2026@aws-1-ap-south-1.pooler.supabase.com:5432/postgres?sslmode=require",
}

print("Testing Supabase connection methods...\n")

for name, conn_string in connections.items():
    try:
        print(f"Testing {name}...")
        conn = psycopg2.connect(conn_string)
        cur = conn.cursor()
        cur.execute('SELECT NOW()')
        result = cur.fetchone()[0]
        print(f"✅ SUCCESS! Server time: {result}\n")
        cur.close()
        conn.close()
        
        # Save working connection to .env
        with open('.env', 'w') as f:
            f.write(f'DATABASE_URL={conn_string}\n')
        print(f"✅ Saved working connection to .env\n")
        break
        
    except Exception as e:
        print(f"❌ Failed: {str(e)[:100]}\n")

print("\nIf all failed, check:")
print("1. Supabase Dashboard > Settings > Database")
print("2. Verify password is: Openkora2026")
print("3. Check if database is paused (unpause it)")
print("4. Try resetting database password")
