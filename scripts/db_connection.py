"""
---------------------------------------------------------------------------
SCRIPT: db_connection.py
TYPE: Application Layer / Orchestrator
AUTHOR: Kilian Sender

DESCRIPTION:
  Executes the "Reorder Alert" pipeline (ELT Pattern).
  1. EXTRACT: Fetches business logic from the SQL Mart layer.
  2. TRANSFORM: Performs final calculations in Python (e.g., coverage %).
  3. LOAD: Generates a formatted Excel report for procurement stakeholders.
---------------------------------------------------------------------------
"""

import os
import sqlite3
import pandas as pd
from openpyxl.utils import get_column_letter

# ==============================================================================
# 1. CONFIGURATION (Infrastructure Settings)
# ==============================================================================
# Define base paths relative to this script
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
# Note: Adjust '..' if script is inside a 'scripts' folder, or remove if in root.
# Assuming structure: /root/scripts/db_connection.py -> DB is in /root/data/
PROJECT_ROOT = os.path.dirname(BASE_DIR) 

DB_PATH = os.path.join(PROJECT_ROOT, "data", "logistik_playground.db")
SQL_SOURCE_FILE = os.path.join(PROJECT_ROOT, "models", "marts", "alert_reorder.sql")
REPORT_OUTPUT_DIR = os.path.join(PROJECT_ROOT, "reports")
REPORT_FILENAME = "dispo_bericht.xlsx"


# ==============================================================================
# 2. HELPER FUNCTIONS (Toolbox)
# ==============================================================================
def load_sql_query(file_path):
    """Reads SQL logic from a separate file to enforce Separation of Concerns."""
    if not os.path.exists(file_path):
        raise FileNotFoundError(f"CRITICAL: SQL Model not found at {file_path}")
    
    with open(file_path, 'r', encoding='utf-8') as f:
        return f.read()

def auto_adjust_excel_width(writer, sheet_name, df):
    """
    UX ENHANCEMENT:
    Auto-scales Excel column widths based on content length.
    Prevents stakeholders from seeing '#####' errors.
    """
    worksheet = writer.sheets[sheet_name]
    for idx, col in enumerate(df.columns):
        series = df[col]
        # Calculate max length of data or header
        max_len = max(
            series.astype(str).map(len).max(),
            len(str(col))
        ) + 2  # Add padding
        
        # Apply width
        worksheet.column_dimensions[get_column_letter(idx + 1)].width = max_len


# ==============================================================================
# 3. MAIN PIPELINE (Orchestration)
# ==============================================================================
def main():
    print("🚀 PIPELINE STARTED: Stockout Alert Report")
    print(f"   Connecting to Database: {os.path.basename(DB_PATH)}")

    conn = None
    try:
        # --- STEP 1: CONNECT & EXTRACT ---
        conn = sqlite3.connect(DB_PATH)
        query = load_sql_query(SQL_SOURCE_FILE)
        
        print(f"   Executing SQL Model: {os.path.basename(SQL_SOURCE_FILE)}...")
        df = pd.read_sql_query(query, conn)
        
        # --- STEP 2: TRANSFORM (Python Layer) ---
        if df.empty:
            print("   ⚠️  NOTICE: No critical items found. Inventory is healthy.")
            return

        # Feature Engineering: Calculate 'Supply Coverage' (Versorgungsgrad)
        # FIX: Nutzung der neuen Englischen Spaltennamen aus dem SQL Report!
        df['supply_coverage_pct'] = df.apply(
            lambda x: round((x['current_stock'] / x['safety_stock_threshold']) * 100, 1) 
            if x['safety_stock_threshold'] > 0 else 0, axis=1
        )
        
        # Business Logic: Filter for high priority (just to be safe)
        row_count = len(df)
        print(f"   ✅ Data Loaded: {row_count} critical items detected.")

        # --- STEP 3: LOAD (Report Generation) ---
        if not os.path.exists(REPORT_OUTPUT_DIR):
            os.makedirs(REPORT_OUTPUT_DIR)
            
        full_output_path = os.path.join(REPORT_OUTPUT_DIR, REPORT_FILENAME)
        
        print(f"   Generating Report: {REPORT_FILENAME}...")
        
        # Using Context Manager for safe file writing
        with pd.ExcelWriter(full_output_path, engine='openpyxl') as writer:
            sheet_name = 'Stockout_Alerts'
            df.to_excel(writer, sheet_name=sheet_name, index=False)
            
            # UX Polish: Auto-format columns
            auto_adjust_excel_width(writer, sheet_name, df)

        print(f"🎉 SUCCESS: Report ready at '{full_output_path}'")
        print("---------------------------------------------------------")
        # Preview for the console user (Updated column names)
        print(df[['article_name', 'supply_coverage_pct', 'deficit_quantity']].head())
        
    except Exception as e:
        print(f"\n❌ CRITICAL ERROR: Pipeline failed.\n{e}")
        raise
    finally:
        if conn:
            conn.close()
            print("   Database connection closed.")

# Entry Point
if __name__ == "__main__":
    main()