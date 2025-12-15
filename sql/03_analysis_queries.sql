/* ---------------------------------------------------
   PROJECT: Inventory Analytics Pipeline
   FILE: 03_analysis_queries.sql
   AUTHOR: Kilian Sender
   DESCRIPTION: 
   This script contains key business questions answered via SQL.
   It covers stock valuation, reorder alerts, and historical tracking.
   ---------------------------------------------------
*/

-- ===================================================
-- 1. MANAGEMENT SUMMARY: LAGERWERT
-- Business Question: Wo ist unser Kapital gebunden?
-- ===================================================

SELECT 
    b.lagerort,
    SUM(b.menge * a.preis_eur) AS aktueller_lagerwert
FROM bewegungen AS b
LEFT JOIN artikel AS a ON b.mat_nr = a.mat_nr
GROUP BY b.lagerort
ORDER BY aktueller_lagerwert DESC;


-- ===================================================
-- 2. OPERATIVE ALARM-LISTE (REORDER REPORT)
-- Business Question: Welche Artikel sind unter Sicherheitsbestand?
-- ===================================================

SELECT 
    a.bezeichnung,
    SUM(b.menge) AS aktueller_bestand,
    a.sicherheitsbestand
FROM bewegungen AS b
LEFT JOIN artikel AS a ON b.mat_nr = a.mat_nr
GROUP BY a.bezeichnung, a.sicherheitsbestand
HAVING SUM(b.menge) < a.sicherheitsbestand;


-- ===================================================
-- 3. AUDIT & HISTORIE
-- Business Question: Was wurde nach dem Stichtag 10.12. gebucht?
-- ===================================================

SELECT 
    buchungsdatum, 
    mat_nr, 
    menge
FROM bewegungen
WHERE buchungsdatum > '2023-12-10'
ORDER BY buchungsdatum ASC;