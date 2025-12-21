
-- A. Die Basics (Fundament) --

-- Befehl,Erklärung,Beispiel / Merksatz --
SELECT,Spalten auswählen.,"""Zeig mir..."""
FROM,Tabelle wählen.,"""...aus dem Regal..."""
WHERE,Filtern vor dem Gruppieren.,"""...aber nur die Roten."""
LEFT JOIN,"Tabellen verknüpfen. Behält alles von links, auch ohne Treffer rechts.","""Hol die Artikel, und wenn da, den Lieferanten dazu."""
INNER JOIN,Tabellen verknüpfen. Nur Treffer auf beiden Seiten.,"""Nur Artikel, die auch einen Lieferanten haben."""
ORDER BY,"Sortieren (ASC = A-Z, DESC = Z-A).","""Sortiere nach Preis absteigend."""
LIMIT,Anzahl Zeilen begrenzen.,"""Zeig nur die Top 5."""

-- B. Data Cleaning & Logik (Der Quality-Check) --

-- Befehl,Erklärung,Beispiel / Merksatz --
COALESCE / IFNULL,Ersetzt NULL durch einen Wert.,"Der Airbag: IFNULL(preis, 0) -> Keine Rechenfehler."
CASE WHEN,Wenn-Dann-Logik (If-Else).,"""Wenn Preis > 100 DANN 'Teuer' SONST 'Billig'."""
CAST,Datentyp ändern (z.B. Text zu Zahl).,"""Mach aus dem Text '10' eine echte Zahl 10."""
ABS,Absoluter Wert (Minuszeichen entfernen).,ABS(-50) wird 50. Wichtig für Mengengerüste.

-- C. Advanced Analytics (Window Functions) --

-- Wichtig: Diese laufen erst im SELECT-Schritt, also NACH dem Filtern! --

-- Befehl,Erklärung,Beispiel / Merksatz --
RANK() OVER ...,"Erstellt eine Rangliste (1, 2, 2, 4...).","""Wer ist der Teuerste?"""
DENSE_RANK() OVER ...,"Wie Rank, aber ohne Lücken (1, 2, 2, 3...).","""Platzierung wie im Sport."""
NTILE(n) OVER ...,Teilt Daten in n Klassen ein (Clustering).,"ABC-Analyse: NTILE(3) macht Low, Mid, High."
LAG() OVER ...,Schaut auf die Zeile davor.,"Zeit-Check: ""Wann war die letzte Buchung?"""
LEAD() OVER ...,Schaut auf die Zeile danach.,"""Wann kommt die nächste Buchung?"""
PARTITION BY,Startet die Berechnung (Rang/Summe) für jede Gruppe neu.,"""Reset des Zählers pro Artikel."""

-- D. Architektur & Struktur --

-- Befehl,Erklärung,Beispiel / Merksatz --
WITH ... AS (...),CTE (Common Table Expression). Temporäre Hilfstabelle.,"Die Zwiebel: ""Erst rechnen, dann filtern."""
CREATE VIEW,Speichert eine Abfrage als virtuelle Tabelle dauerhaft.,"""Clean Code: Logik einmal bauen, immer nutzen."""

-- E. Zeit-Berechnung (SQLite Spezifikum) --
-- Befehl,Erklärung,Beispiel / Merksatz --
JULIANDAY(),Wandelt Datum in Zahl um (Tage seit 4713 v. Chr.).,"Nötig, um Tage zu subtrahieren: Tag_neu - Tag_alt."