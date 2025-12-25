/* ---------------------------------------------------------------------------
   FILE: models/marts/supplier_last_contact.sql
   LAYER: Marts (Procurement & Quality)
   BUSINESS OBJECTIVE: Supplier Reliability & Lifecycle Management
   
   DESCRIPTION: 
     Evaluates supplier activity based on the latest inbound transactions.
     Combines "Recency" (Days since last contact) with "Quality" (Rating)
     to recommend strategic actions (e.g., Reactivate vs. Delist).
     
     Logic: Uses Window Functions to isolate the most recent interaction.
   ---------------------------------------------------------------------------
*/

WITH latest_movement_log AS (
    SELECT 
        -- 1. Fetch Key Entities (using German schema columns, aliasing to English)
        l.lieferanten_id,
        l.firmen_name AS supplier_name,
        l.stadt AS location,
        l.rating AS supplier_score, -- Quality Rating (1-5 from Setup)
        
        a.bezeichnung AS last_supplied_item,
        b.buchungsdatum AS transaction_date,
        
        -- 2. Window Function: Rank by Recency
        -- Assigns Rank 1 to the very last delivery per supplier.
        RANK() OVER (
            PARTITION BY l.firmen_name 
            ORDER BY b.buchungsdatum DESC
        ) AS recency_rank
        
    FROM bewegungen AS b
    -- Contextualize movements with Master Data
    LEFT JOIN artikel AS a ON b.mat_nr = a.mat_nr 
    -- Link to Supplier Data (using the keys defined in 01_setup_schema.sql)
    LEFT JOIN lieferanten AS l ON a.lieferanten_id = l.lieferanten_id
    
    WHERE l.firmen_name IS NOT NULL -- Exclude items with no assigned supplier
)

-- 3. Final Reporting Layer
SELECT 
    supplier_name,
    location,
    supplier_score,
    last_supplied_item,
    transaction_date AS last_interaction_date,
    
    -- Metric: Days Inactive
    -- Calculates the gap between today and the last delivery.
    CAST((JULIANDAY('now') - JULIANDAY(transaction_date)) AS INTEGER) AS days_inactive,
    
    -- Logic: Strategic Recommendation Matrix
    CASE 
        -- High Rated but Dormant -> Potential lost value!
        WHEN (JULIANDAY('now') - JULIANDAY(transaction_date)) > 180 AND supplier_score >= 4 
            THEN 'SLEEPING CHAMPION (Re-Engage!)'
            
        -- Low Rated and Dormant -> Clean up master data
        WHEN (JULIANDAY('now') - JULIANDAY(transaction_date)) > 180 AND supplier_score < 3 
            THEN 'PURGE CANDIDATE (Delist)'
            
        -- Standard Dormancy
        WHEN (JULIANDAY('now') - JULIANDAY(transaction_date)) > 90 
            THEN 'Review Needed'
            
        ELSE 'Active'
    END AS strategic_action

FROM latest_movement_log
WHERE recency_rank = 1 -- Filter: Keep only the latest interaction
ORDER BY days_inactive DESC;