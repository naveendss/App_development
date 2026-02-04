import psycopg2
import os
from dotenv import load_dotenv

load_dotenv()

try:
    conn = psycopg2.connect(os.getenv('DATABASE_URL'))
    cur = conn.cursor()
    cur.execute('SELECT NOW()')
    print('✅ Connection successful!')
    print('📅 Server time:', cur.fetchone()[0])
    cur.close()
    conn.close()
except Exception as e:
    print('❌ Connection failed:', e)
