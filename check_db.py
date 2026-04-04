import sqlite3
import os

db_path = r"c:\Users\kaust\Mediguide_Project\PROJECT\sql_app.db"
if os.path.exists(db_path):
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
    tables = cursor.fetchall()
    print("Tables in sql_app.db:", tables)
    for table in tables:
        table_name = table[0]
        cursor.execute(f"PRAGMA table_info({table_name});")
        print(f"Columns in {table_name}:", cursor.fetchall())
    conn.close()
else:
    print("sql_app.db not found")

db_path_2 = r"c:\Users\kaust\Mediguide_Project\PROJECT\homeo.db"
if os.path.exists(db_path_2):
    conn = sqlite3.connect(db_path_2)
    cursor = conn.cursor()
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
    tables = cursor.fetchall()
    print("Tables in homeo.db:", tables)
    for table in tables:
        table_name = table[0]
        cursor.execute(f"PRAGMA table_info({table_name});")
        print(f"Columns in {table_name}:", cursor.fetchall())
    conn.close()
else:
    print("homeo.db not found")
