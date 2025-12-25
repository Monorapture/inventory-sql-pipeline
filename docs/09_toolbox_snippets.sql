/* ---------------------------------------------------------------------------
   FILE: 09_toolbox_snippets.sql
   AUTHOR: Kilian Sender
   DESCRIPTION: 
     A collection of reusable SQL patterns for logistics data analysis.
     Includes templates for Window Functions, CTEs, and Aggregations.
     Used as a quick reference for building robust data models.
   ---------------------------------------------------------------------------
*/

-- ===================================================
-- 1. DATA RETRIEVAL & ALIASING
-- Pattern: Renaming columns to match business terminology
-- ===================================================
SELECT 
    mat_nr AS article_id,
    bezeichnung AS article_name,
    preis_eur AS unit_cost
FROM artikel;


-- ===================================================
-- 2. FILTERING LOGIC (PREDICATES)
-- Pattern: Isolating specific segments (e.g., High-Value Items)
-- ===================================================
SELECT * FROM artikel
WHERE preis_eur > 100 
  AND kategorie = 'Elektro';


-- ===================================================
-- 3. AGGREGATION & DISTRIBUTION
-- Pattern: Grouping data to analyze category density
-- ===================================================
SELECT 
    kategorie AS category, 
    COUNT(*) AS item_count,
    ROUND(AVG(preis_eur), 2) AS avg_price
FROM artikel
GROUP BY kategorie;


-- ===================================================
-- 4. WINDOW FUNCTIONS: CUMULATIVE SUM
-- Business Case: Tracking inventory value buildup over time
-- ===================================================
SELECT 
    buchungsdatum,
    menge,
    -- Calculates a running total ordered by date
    SUM(menge) OVER (ORDER BY buchungsdatum) AS running_total_stock
FROM bewegungen;


-- ===================================================
-- 5. WINDOW FUNCTIONS: RANKING
-- Business Case: Identifying top-value items (e.g., for ABC Analysis)
-- ===================================================
SELECT 
    bezeichnung, 
    preis_eur,
    -- Ranks items by price (1 = most expensive)
    RANK() OVER (ORDER BY preis_eur DESC) AS price_rank
FROM artikel;


-- ===================================================
-- 6. COMMON TABLE EXPRESSIONS (CTE)
-- Pattern: Modularizing complex queries for better readability.
-- Replaces nested subqueries with a linear logic flow.
-- ===================================================

-- Step 1: Define the temporary result set
WITH high_value_items AS (
    SELECT mat_nr, bezeichnung 
    FROM artikel 
    WHERE preis_eur > 500
)

-- Step 2: Use the result set in the main query
SELECT 
    h.bezeichnung, 
    b.buchungsdatum, 
    b.menge
FROM bewegungen AS b