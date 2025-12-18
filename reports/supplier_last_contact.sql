/* FILE: lieferanten_letzter_kontakt_analyse.sql
   AUTHOR: Kilian Sender
   DATE: 15.12.2025
   DESCRIPTION: 
     Ermittelt das Datum des letzten Kontakts pro Lieferant.
     Nutzt Window Functions (RANK) und CTEs, um nur die jeweils 
     jüngste Buchung zu filtern.
   STACK: SQLite
*/
WITH lieferanten_log AS(
SELECT 
	l.lieferanten_id,     
	l.firmen_name,
	b.menge,
    a.bezeichnung,
    b.buchungsdatum,
    RANK() OVER (
        PARTITION BY l.firmen_name   
        ORDER BY b.buchungsdatum DESC      
    ) AS letzter_kontakt
FROM bewegungen AS b
LEFT JOIN artikel AS a ON b.mat_nr = a.mat_nr 
LEFT JOIN lieferanten AS l ON l.lieferanten_id = a.lieferanten_id
)

SELECT * FROM lieferanten_log
WHERE letzter_kontakt = 1
ORDER BY lieferanten_id ASC;