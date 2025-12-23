-- FILE: models/intermediate/int_inventory_levels.sql

-- 1. Erst den alten (kaputten) View löschen!
DROP VIEW IF EXISTS int_inventory_levels;

-- 2. Jetzt den neuen sauber anlegen
CREATE VIEW int_inventory_levels AS
SELECT
    a.mat_nr,
    a.bezeichnung,
    b.lagerort AS stamm_lagerort, -- KORREKT: b.lagerort (aus Bewegungen)
    a.preis_eur,
    a.sicherheitsbestand,
    COALESCE(SUM(b.menge), 0) as aktueller_bestand
FROM artikel AS a
LEFT JOIN bewegungen AS b ON a.mat_nr = b.mat_nr
GROUP BY 
    a.mat_nr, 
    a.bezeichnung, 
    b.lagerort, 
    a.preis_eur,
    a.sicherheitsbestand;