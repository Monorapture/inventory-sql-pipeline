-- FILE: models/marts/alert_reorder.sql
-- BUSINESS QUESTION: Was müssen wir nachbestellen?

SELECT 
    bezeichnung,
    aktueller_bestand,
    sicherheitsbestand,
    (sicherheitsbestand - aktueller_bestand) as fehlmenge
FROM int_inventory_levels
WHERE aktueller_bestand < sicherheitsbestand
ORDER BY fehlmenge DESC;