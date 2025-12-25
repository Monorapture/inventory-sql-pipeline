/* ---------------------------------------------------------------------------
   FILE: models/marts/report_lagerwert.sql
   LAYER: Marts (Finance & Controlling)
   BUSINESS OBJECTIVE: Capital Allocation Analysis
   
   DESCRIPTION: 
     Aggregates inventory value by physical location to identify 
     capital lockup ("Totes Kapital").
     
     Used by Management/Finance to answer: 
     "How much money is sitting on the shelf right now?"
   ---------------------------------------------------------------------------
*/

SELECT 
    current_location AS warehouse_location,
    
    -- KPI: Total Monetary Value
    -- Calculation: Quantity * Unit Cost
    SUM(current_stock_level * unit_cost) AS bound_capital_eur

FROM int_inventory_levels -- Consuming the Pre-Calculated View

GROUP BY current_location
ORDER BY bound_capital_eur DESC;