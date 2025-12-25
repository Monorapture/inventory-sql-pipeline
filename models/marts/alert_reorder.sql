/* ---------------------------------------------------------------------------
   FILE: models/marts/alert_reorder.sql
   LAYER: Marts (Operational Logistics)
   BUSINESS OBJECTIVE: Stockout Prevention / Risk Management
   
   DESCRIPTION: 
     Filters for items where current stock has breached the safety threshold.
     Calculates the exact deficit quantity ("Fehlmenge") for immediate 
     procurement action.
     
     Trigger: Run daily before the procurement window closes.
   ---------------------------------------------------------------------------
*/

SELECT 
    article_name,
    current_stock_level AS current_stock,
    safety_stock_threshold,
    
    -- Derived Metric: Deficit (Net Demand)
    -- Calculates the quantity required to restore safety stock levels.
    (safety_stock_threshold - current_stock_level) as deficit_quantity

FROM int_inventory_levels -- Consuming the Single Source of Truth

WHERE 
    -- LOGIC: Criticality Filter
    -- Only identifies items where physical stock has dropped below the safety buffer.
    current_stock_level < safety_stock_threshold

ORDER BY deficit_quantity DESC;