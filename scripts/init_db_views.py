"""
---------------------------------------------------------------------------
SCRIPT: init_db_views.py
TYPE: Infrastructure / Schema Migration
AUTHOR: Kilian Sender

DESCRIPTION:
  Deploys the SQL logic layer (Views) into the SQLite database.
  
  This script ensures the 'Intermediate Layer' exists before any 
  Data Marts or Reports try to access it.
  
  It follows the IDEMPOTENCY principle: 
  Can be run multiple times without causing duplication errors 
  (due to DROP VIEW IF EXISTS logic in the SQL files).
---------------------------------------------------------------------------
"""

import os
import sqlite3

# ==============================================================================
# 1. CONFIGURATION (Path Management)
# ==============================================================================
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(BASE_DIR)

DB_PATH = os.path.join(PROJECT_ROOT, "data", "logistik_playground.db")
VIEW_SOURCE_FILE = os.path.join(PROJECT_ROOT, "models", "intermediate", "int_inventory_levels.sql")

# ==============================================================================
# 2. HELPER FUNCTIONS
# ==============================================================================
def read_sql_file(file_path):
    """Safe file reading with error handling."""
    if not os.path.exists(file_path):
        raise FileNotFoundError(f"CRITICAL: SQL Definition not found at {file_path}")
    
    with open(file_path, 'r', encoding='utf-8') as f:
        return f.read()

# ==============================================================================
# 3. MIGRATION LOGIC
# ==============================================================================
def main():
    print("🛠️  STARTING SCHEMA MIGRATION...")
    print(f"    Target Database: {os.path.basename(DB_PATH)}")

    conn = None
    try:
        # A. Establish Connection
        conn = sqlite3.connect(DB_PATH)
        
        # B. Read the Architecture Definition (The SQL View)
        print(f"    Reading Definition: {os.path.basename(VIEW_SOURCE_FILE)}...")
        view_sql = read_sql_file(VIEW_SOURCE_FILE)
        
        # C. Execute DDL (Data Definition Language)
        # executescript() is used because the SQL file contains multiple statements
        # (DROP VIEW ... ; CREATE VIEW ...)
        conn.executescript(view_sql)
        
        print("    ✅ SUCCESS: View 'int_inventory_levels' deployed/updated.")
        print("    The Logic Layer is now in sync with the code.")

    except sqlite3.Error as e:
        print(f"\n❌ DATABASE ERROR: Migration failed.\n{e}")
    except Exception as e:
        print(f"\n❌ SYSTEM ERROR: {e}")
    finally:
        if conn:
            conn.close()
            print("    Connection closed.")

if __name__ == "__main__":
    main()