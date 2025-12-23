import os
import sqlite3

# 1. SETUP
db_path = "data/logistik_playground.db"
view_file_path = "models/intermediate/int_inventory_levels.sql"

# 2. HILFSFUNKTION (Kennen wir schon)
def get_sql_from_file(file_path):
    if not os.path.exists(file_path):
        raise FileNotFoundError(f"Fehler: {file_path} fehlt!")
    with open(file_path, 'r', encoding='utf-8') as f:
        return f.read()

# 3. AUSFÜHRUNG (Der Bau-Trupp)
conn = sqlite3.connect(db_path)
print("🔌 Verbindung hergestellt. Starte Aufbau der Views...")

try:
    # A. Den Bauplan lesen
    create_view_sql = get_sql_from_file(view_file_path)
    print(f"📄 Lese Bauplan: {view_file_path}")
    
    # B. Den Bauplan ausführen (Das Regal aufbauen)
    # cursor().executescript() ist wichtig, falls mehrere Befehle drin sind
    conn.executescript(create_view_sql)
    
    print("✅ ERFOLG: View 'int_inventory_levels' wurde erstellt/aktualisiert!")

except Exception as e:
    print(f"❌ FEHLER beim Erstellen des Views:\n{e}")

finally:
    conn.close()