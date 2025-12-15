import os
import sqlite3
import pandas as pd

# 1. VERBINDUNG HERSTELLEN (Connect)
# Achte darauf, dass der Pfad zu deiner .db Datei stimmt!
# Wenn die Datei im selben Ordner liegt, reicht der Dateiname.
db_path = "data\logistik_playground.db" 
conn = sqlite3.connect(db_path)

print("Verbindung zur Datenbank hergestellt! 🔌")

# 2. DIE SQL-ABFRAGE (Query)
# Das ist genau der Code, den wir eben in DBeaver entwickelt haben
sql_query = """
SELECT 
    a.bezeichnung,
    SUM(b.menge) AS aktueller_bestand,
    a.sicherheitsbestand
FROM bewegungen AS b
LEFT JOIN artikel AS a ON b.mat_nr = a.mat_nr
GROUP BY a.bezeichnung, a.sicherheitsbestand
HAVING SUM(b.menge) < a.sicherheitsbestand;
"""

# 3. DATEN LADEN (Extract)
# Pandas führt das SQL für dich aus und packt das Ergebnis in einen DataFrame
df_kritisch = pd.read_sql(sql_query, conn)

# 4. VERBINDUNG SCHLIESSEN (Wichtig!)
conn.close()

# 5. ANALYSE IN PYTHON
print("\n--- KRITISCHE ARTIKEL (Reorder Report) ---")
print(df_kritisch)

# Bonus: Wir können jetzt mit Pandas weiterrechnen!
# Z.B. Wie viel % vom Sicherheitsbestand haben wir noch?
df_kritisch['versorgung_prozent'] = (df_kritisch['aktueller_bestand'] / df_kritisch['sicherheitsbestand']) * 100
df_kritisch['versorgung_prozent'] = df_kritisch['versorgung_prozent'].round(1)

print("\n--- ANALYSE MIT PYTHON-POWER ---")
print(df_kritisch[['bezeichnung', 'versorgung_prozent']])

# REPORT SPEICHERN
output_folder = "reports"
dateiname = "dispo_bericht.xlsx"

# 1. Prüfen, ob der Ordner existiert. Wenn nicht: Erstellen!
if not os.path.exists(output_folder):
    os.makedirs(output_folder)
    print(f"Ordner '{output_folder}' wurde erstellt.")

# 2. Pfad zusammenbauen
speicher_pfad = os.path.join(output_folder, dateiname)

# 3. Speichern mit AUTOSCALE (Der Profi-Weg)
# Wir nutzen einen "Context Manager" (das 'with'), um die Datei zu bearbeiten
with pd.ExcelWriter(speicher_pfad, engine='openpyxl') as writer:
    
    # Erstmal die Daten ganz normal reinschreiben
    sheet_name = 'Report'
    df_kritisch.to_excel(writer, sheet_name=sheet_name, index=False)
    
    # Jetzt holen wir uns das "Arbeitsblatt"-Objekt, um es zu bearbeiten
    worksheet = writer.sheets[sheet_name]
    
    # Wir loopen durch alle Spalten
    for column in worksheet.columns:
        max_length = 0
        column_letter = column[0].column_letter # z.B. "A", "B", "C"
        
        # Wir gehen jede Zelle in der Spalte durch und suchen den längsten Text
        for cell in column:
            try:
                if len(str(cell.value)) > max_length:
                    max_length = len(str(cell.value))
            except:
                pass
        
        # Wir setzen die Breite auf Textlänge + 2 (Puffer, damit es nicht klebt)
        adjusted_width = (max_length + 2)
        worksheet.column_dimensions[column_letter].width = adjusted_width

print(f"✅ Report erfolgreich gespeichert (mit Autoscale): {speicher_pfad}")