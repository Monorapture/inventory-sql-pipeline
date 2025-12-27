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

import sqlite3
import pandas as pd
from openpyxl.utils import get_column_letter
from pathlib import Path  # Modern standard (replaces os.path)

# ==============================================================================
# 1. CONFIGURATION (Infrastructure Settings)
# ==============================================================================
# First Principle: Navigation via Objects, not Strings.
# .resolve() ensures we have the absolute path (resolves symlinks).
SCRIPT_DIR = Path(__file__).resolve().parent

# Navigation: .parent is more intuitive than os.path.dirname()
# Assumption: /root/scripts/db_connection.py -> Project Root is one level up
PROJECT_ROOT = SCRIPT_DIR.parent 

# Path construction using the "/" operator (Cross-platform compatible)
DB_PATH = PROJECT_ROOT / "data" / "logistik_playground.db"
SQL_SOURCE_FILE = PROJECT_ROOT / "models" / "marts" / "alert_reorder.sql"
REPORT_OUTPUT_DIR = PROJECT_ROOT / "reports"
REPORT_FILENAME = "dispo_bericht.xlsx"


# ==============================================================================
# 2. HELPER FUNCTIONS (Toolbox)
# ==============================================================================
def load_sql_query(file_path: Path):
    """
    Reads SQL logic using pathlib methods.
    Type Hinting (file_path: Path) enforces robust interface design.
    """
    # OOP-style check: The object itself knows if it exists.
    if not file_path.exists():
        raise FileNotFoundError(f"CRITICAL: SQL Model not found at {file_path}")
    
    # Clean Code: .read_text() automatically handles open/read/close.
    # Eliminates the need for verbose 'with open(...) as f' blocks.
    return file_path.read_text(encoding='utf-8')

def auto_adjust_excel_width(writer, sheet_name, df):
    """
    UX ENHANCEMENT:
    Auto-scales Excel column widths based on content length.
    Prevents stakeholders from seeing '#####' errors in the report.
    """
    worksheet = writer.sheets[sheet_name]
    for idx, col in enumerate(df.columns):
        series = df[col]
        # Calculate max length of data or header to determine width
        max_len = max(
            series.astype(str).map(len).max(),
            len(str(col))
        ) + 2  # Add padding for better readability
        
        worksheet.column_dimensions[get_column_letter(idx + 1)].width = max_len


# ==============================================================================
# 3. MAIN PIPELINE (Orchestration)
# ==============================================================================
def main():
    print("🚀 PIPELINE STARTED: Stockout Alert Report")
    # .name returns just the filename (e.g., 'logistik_playground.db')
    print(f"   Connecting to Database: {DB_PATH.name}")

    conn = None
    try:
        # --- STEP 1: CONNECT & EXTRACT ---
        # sqlite3 accepts Path objects directly
        conn = sqlite3.connect(DB_PATH)
        query = load_sql_query(SQL_SOURCE_FILE)
        
        print(f"   Executing SQL Model: {SQL_SOURCE_FILE.name}...")
        df = pd.read_sql_query(query, conn)
        
        # --- STEP 2: TRANSFORM (Python Layer) ---
        if df.empty:
            print("   ⚠️  NOTICE: No critical items found. Inventory is healthy.")
            return

        # Feature Engineering: Calculate 'Supply Coverage'
        # Vectorized calculation using apply() for row-wise logic
        df['supply_coverage_pct'] = df.apply(
            lambda x: round((x['current_stock'] / x['safety_stock_threshold']) * 100, 1) 
            if x['safety_stock_threshold'] > 0 else 0, axis=1
        )
        
        row_count = len(df)
        print(f"   ✅ Data Loaded: {row_count} critical items detected.")

        # --- STEP 3: LOAD (Report Generation) ---
        # Create directory if it doesn't exist.
        # parents=True creates missing parent folders; exist_ok=True prevents errors.
        REPORT_OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
            
        full_output_path = REPORT_OUTPUT_DIR / REPORT_FILENAME
        
        print(f"   Generating Report: {REPORT_FILENAME}...")
        
        # Using Context Manager for safe file writing
        with pd.ExcelWriter(full_output_path, engine='openpyxl') as writer:
            sheet_name = 'Stockout_Alerts'
            df.to_excel(writer, sheet_name=sheet_name, index=False)
            
            # UX Polish: Auto-format columns
            auto_adjust_excel_width(writer, sheet_name, df)

        print(f"🎉 SUCCESS: Report ready at '{full_output_path}'")
        print("---------------------------------------------------------")
        
        # Console Preview for the operator
        print(df[['article_name', 'supply_coverage_pct', 'deficit_quantity']].head())
        
    except Exception as e:
        print(f"\n❌ CRITICAL ERROR: Pipeline failed.\n{e}")
        raise
    finally:
        # Resource Management: Ensure connection is closed even if pipeline fails
        if conn:
            conn.close()
            print("   Database connection closed.")

# Entry Point
if __name__ == "__main__":
    main()