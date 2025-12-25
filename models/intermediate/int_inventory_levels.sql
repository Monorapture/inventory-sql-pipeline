/* ---------------------------------------------------------------------------
   FILE: models/intermediate/int_inventory_levels.sql
   LAYER: Intermediate (Business Logic / Transformation)
   STATUS: Production Ready
   
   DESCRIPTION: 
     Acts as the "Single Source of Truth" (SSOT) for inventory metrics.
     It joins Master Data (Articles) with Transaction Data (Movements) 
     to calculate current stock levels and valuations.

   ARCHITECTURAL DECISION:
     This View abstracts the calculation logic away from the final reports.
     Any change to "how stock is calculated" only needs to be updated here, 
     propagating automatically to all downstream marts.
   ---------------------------------------------------------------------------
*/

-- 1. Idempotency: Ensure a clean slate before recreation (Self-Healing)
DROP VIEW IF EXISTS int_inventory_levels;

-- 2. Definition: Create the persisted logic layer
CREATE VIEW int_inventory_levels AS
SELECT
    -- Dimension: Master Data (Context)
    a.mat_nr, 
    a.bezeichnung AS article_name,
    
    -- Dimension: Physical Location
    -- Derived from transaction stream (b) to reflect actual storage vs. planned storage
    b.lagerort AS current_location, 
    
    -- Measures: Valuation & Constraints
    a.preis_eur AS unit_cost,
    a.sicherheitsbestand AS safety_stock_threshold,
    
    -- KPI Calculation: Current Stock
    -- Using COALESCE to handle NULLs (items with no movements = 0 stock)
    -- This prevents mathematical errors in downstream reports.
    COALESCE(SUM(b.menge), 0) as current_stock_level

FROM artikel AS a
-- JOIN Strategy: LEFT JOIN ensures we retain all Master Data records, 
-- even if no transaction history exists (detects "Dead Stock").
LEFT JOIN bewegungen AS b ON a.mat_nr = b.mat_nr

GROUP BY 
    a.mat_nr, 
    a.bezeichnung, 
    b.lagerort, 
    a.preis_eur,
    a.sicherheitsbestand;