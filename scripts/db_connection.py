import os
import sqlite3
import pandas as pd

# ---------------------------------------------------------
# 1. HILFSFUNKTION (Das Werkzeug)
# ---------------------------------------------------------
def get_sql_from_file(file_path):
    """
    Liest den Inhalt einer .sql Datei und gibt ihn als String zurück.
    """
    if not os.path.exists(file_path):
        raise FileNotFoundError(f"Fehler: Die Datei '{file_path}' wurde nicht gefunden!")
        
    with open(file_path, 'r', encoding='utf-8') as f:
        return f.read()

# ---------------------------------------------------------
# 2. SETUP (Pfade definieren)
# ---------------------------------------------------------
db_path = "data/logistik_playground.db"
sql_file_path = "models/marts/alert_reorder.sql" 

# ---------------------------------------------------------
# 3. VERBINDUNG & ABLAUF
# ---------------------------------------------------------
conn = sqlite3.connect(db_path)
print("Verbindung zur Datenbank hergestellt! 🔌")

try:
    # --- SCHRITT A: SQL LADEN ---
    print(f"Lese SQL aus: {sql_file_path} ...")
    sql_query = get_sql_from_file(sql_file_path)
    
    # Optional: Zur Kontrolle die ersten 100 Zeichen anzeigen
    print(f"--- SQL geladen (Vorschau): ---\n{sql_query[:100]}...\n-------------------------------")

    # --- SCHRITT B: DATENBANK ABFRAGEN ---
    df_kritisch = pd.read_sql(sql_query, conn)
    
    # --- SCHRITT C: ANALYSE (Nur wenn Daten da sind!) ---
    if df_kritisch.empty:
        print("⚠️ Keine kritischen Artikel gefunden. Report ist leer.")
    else:
        print("\n--- ERGEBNIS (Kritische Artikel) ---")
        print(df_kritisch)

        # Bonus-Rechnung
        df_kritisch['versorgung_prozent'] = (df_kritisch['aktueller_bestand'] / df_kritisch['sicherheitsbestand']) * 100
        df_kritisch['versorgung_prozent'] = df_kritisch['versorgung_prozent'].round(1)

        print("\n--- ANALYSE MIT PYTHON-POWER ---")
        print(df_kritisch[['bezeichnung', 'versorgung_prozent']])

        # --- SCHRITT D: REPORT SPEICHERN ---
        output_folder = "reports"
        dateiname = "dispo_bericht.xlsx"

        if not os.path.exists(output_folder):
            os.makedirs(output_folder)
            print(f"Ordner '{output_folder}' wurde erstellt.")

        speicher_pfad = os.path.join(output_folder, dateiname)

        with pd.ExcelWriter(speicher_pfad, engine='openpyxl') as writer:
            sheet_name = 'Report'
            df_kritisch.to_excel(writer, sheet_name=sheet_name, index=False)
            
            worksheet = writer.sheets[sheet_name]
            for column in worksheet.columns:
                max_length = 0
                column_letter = column[0].column_letter
                for cell in column:
                    try:
                        if len(str(cell.value)) > max_length:
                            max_length = len(str(cell.value))
                    except:
                        pass
                adjusted_width = (max_length + 2)
                worksheet.column_dimensions[column_letter].width = adjusted_width

        print(f"✅ Report erfolgreich gespeichert (mit Autoscale): {speicher_pfad}")

except Exception as e:
    print(f"\n❌ FEHLER: Ein kritisches Problem ist aufgetreten:\n{e}")
    # Hier endet das Programm sauber, ohne Folgefehler.

finally:
    conn.close()
    print("\nVerbindung geschlossen.")