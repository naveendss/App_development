import psycopg2
import os
from pathlib import Path
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.getenv('DATABASE_URL')
MIGRATIONS = [
    '001_create_core_tables.sql',
    '002_create_booking_tables.sql',
    '003_create_community_tables.sql',
    '004_create_views_and_functions.sql',
    '005_add_password_to_users.sql',
    '006_add_max_bookings_per_week.sql'
]

def run_migrations():
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()
    
    try:
        print('🔌 Connected to database\n')
        
        cur.execute("""
            CREATE TABLE IF NOT EXISTS schema_migrations (
                id SERIAL PRIMARY KEY,
                migration_name VARCHAR(255) UNIQUE NOT NULL,
                executed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
            );
        """)
        conn.commit()
        
        for filename in MIGRATIONS:
            cur.execute("SELECT * FROM schema_migrations WHERE migration_name = %s", (filename,))
            if cur.fetchone():
                print(f'⏭️  Skipping {filename}')
                continue
            
            print(f'🚀 Running {filename}')
            sql = Path(f'migrations/{filename}').read_text()
            cur.execute(sql)
            cur.execute("INSERT INTO schema_migrations (migration_name) VALUES (%s)", (filename,))
            conn.commit()
            print(f'✅ Completed {filename}\n')
        
        print('🎉 All migrations completed!')
        
    except Exception as e:
        print(f'❌ Error: {e}')
        conn.rollback()
    finally:
        cur.close()
        conn.close()

if __name__ == '__main__':
    run_migrations()
