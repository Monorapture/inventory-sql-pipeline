-- FILE: models/marts/report_lagerwert.sql
-- BUSINESS QUESTION: Wo ist Kapital gebunden?

SELECT 
    stamm_lagerort,
    SUM(aktueller_bestand * preis_eur) AS gebundenes_kapital
FROM int_inventory_levels
GROUP BY stamm_lagerort
ORDER BY gebundenes_kapital DESC;