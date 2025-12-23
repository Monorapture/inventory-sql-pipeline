-- DATEN LADEN (Das würde normalerweise SAP machen)

-- Artikel anlegen
INSERT INTO artikel (mat_nr, bezeichnung, kategorie, preis_eur, sicherheitsbestand) VALUES 
(1001, 'Sicherungsschalter 16A', 'Elektro', 12.50, 100),
(1002, 'Smart Meter Gateway', 'Messwesen', 150.00, 20),
(1003, 'Kupferkabel Rolle 50m', 'Kabel', 85.90, 10),
(1004, 'Isolierband', 'Verbrauch', 2.50, 500),
(1005, 'Trafo-Station Modul B', 'Großteile', 2500.00, 2);

-- Bewegungen simulieren (Historie)
INSERT INTO bewegungen (mat_nr, buchungsdatum, bewegungstyp, menge, lagerort, user_id) VALUES
(1001, '2023-12-01', 'WE', 500, 'REGAL-A-01', 'MUELLER'),
(1002, '2023-12-02', 'WE', 50, 'SECURE-01', 'SCHMIDT'),
(1001, '2023-12-05', 'WA', -20, 'REGAL-A-01', 'BAUER'), -- Entnahme für Auftrag
(1003, '2023-12-06', 'WE', 20, 'REGAL-B-02', 'MUELLER'),
(1005, '2023-12-10', 'WE', 5, 'FREILAGER', 'LKW-FAHRER'),
(1001, '2023-12-12', 'WA', -50, 'REGAL-A-01', 'BAUER'),
(1002, '2023-12-15', 'WA', -5, 'SECURE-01', 'SCHMIDT'),
(1004, '2023-12-20', 'WE', 1000, 'REGAL-C-05', 'MUELLER'),
(1001, '2023-12-22', 'WA', -400, 'REGAL-A-01', 'BAUER'); -- Großer Auftrag!