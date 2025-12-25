/* ---------------------------------------------------------------------------
   FILE: 03_analysis_queries.sql
   STATUS: Legacy / Ad-hoc
   DESCRIPTION: 
     Original monolithic analysis scripts used before the migration to the 
     modular ELT pipeline (models/marts).
     
     Kept for reference and quick ad-hoc checks on raw data.
   ---------------------------------------------------------------------------
*/

-- ===================================================
-- 1. KPI ANALYSIS: CAPITAL LOCKUP
-- Business Objective: Identify capital tied up in inventory per location.
-- Use Case: Warehouse optimization & liquidity planning.
-- ===================================================
SELECT 
    b.lagerort AS location,
    SUM(b.menge * a.preis_eur) AS total_inventory_value
FROM bewegungen AS b
LEFT JOIN artikel AS a ON b.mat_nr = a.mat_nr
GROUP BY b.lagerort
ORDER BY total_inventory_value DESC;


-- ===================================================
-- 2. RISK MANAGEMENT: STOCKOUT DETECTION
-- Business Objective: Detect items falling below Safety Stock levels.
-- Logic: Aggregates movements and compares against master data constraints.
-- ===================================================
SELECT 
    a.bezeichnung AS article_name,
    SUM(b.menge) AS current_stock,
    a.sicherheitsbestand AS safety_stock_threshold
FROM bewegungen AS b
LEFT JOIN artikel AS a ON b.mat_nr = a.mat_nr
GROUP BY a.bezeichnung, a.sicherheitsbestand
HAVING SUM(b.menge) < a.sicherheitsbestand;


-- ===================================================
-- 3. FORENSIC ANALYSIS: AUDIT TRAIL
-- Business Objective: Trace transaction history after a specific cutoff date.
-- Use Case: Audit preparation or investigating inventory discrepancies.
-- ===================================================
SELECT 
    buchungsdatum AS transaction_date, 
    mat_nr AS article_id, 
    menge AS quantity
FROM bewegungen
WHERE buchungsdatum > '2023-12-10'
ORDER BY buchungsdatum ASC;