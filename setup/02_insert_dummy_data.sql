/* ---------------------------------------------------------------------------
   FILE: setup/02_insert_dummy_data.sql
   TYPE: Data Seeding (Mock Data)
   DESCRIPTION: 
     Populates the database with synthetic data to simulate an ERP export.
     Used for testing the ELT pipeline and dashboard visualization.
   ---------------------------------------------------------------------------
*/

-- ===================================================
-- 1. SEED MASTER DATA (Lieferanten & Artikel)
-- ===================================================

-- Create Suppliers first (needed for Foreign Keys)
INSERT INTO lieferanten (firmen_name, stadt, rating) VALUES 
('ElectroSupply GmbH', 'Hamburg', 5),      -- Tier 1 Supplier
('Global Tech Imports', 'Berlin', 3),      -- Tier 2 Supplier
('Billig-Bauteile 24', 'München', 1);      -- High Risk Supplier

-- Create Articles (Assigned to Suppliers)
INSERT INTO artikel (mat_nr, bezeichnung, kategorie, preis_eur, sicherheitsbestand, lieferanten_id) VALUES 
(1001, 'Sicherungsschalter 16A', 'Elektro', 12.50, 100, 1),
(1002, 'Smart Meter Gateway', 'Messwesen', 150.00, 20, 2),
(1003, 'Kupferkabel Rolle 50m', 'Kabel', 85.90, 10, 1),
(1004, 'Isolierband', 'Verbrauch', 2.50, 500, 3),
(1005, 'Trafo-Station Modul B', 'Großteile', 2500.00, 2, 2);


-- ===================================================
-- 2. SEED TRANSACTION DATA (Bewegungen)
-- ===================================================

INSERT INTO bewegungen (mat_nr, buchungsdatum, bewegungstyp, menge, lagerort, user_id) VALUES
-- Initial Stock (Inbound)
(1001, '2023-12-01', 'WE', 500, 'REGAL-A-01', 'MUELLER'),
(1002, '2023-12-02', 'WE', 50, 'SECURE-01', 'SCHMIDT'),
-- Consumption (Outbound)
(1001, '2023-12-05', 'WA', -20, 'REGAL-A-01', 'BAUER'),
(1003, '2023-12-10', 'WE', 200, 'KABEL-LAGER', 'MUELLER'),
-- Critical Item Simulation (Stock drops below Safety Stock)
(1004, '2024-01-15', 'WE', 10, 'REGAL-B-05', 'SCHMIDT'); -- Nur 10 Isolierbänder, Soll: 500!


-- ===================================================
-- 3. SEED CRM DATA (Kommunikation)
-- ===================================================

INSERT INTO kommunikation (lieferanten_id, datum, kanal, betreff) VALUES 
(1, DATE('now', '-2 days'), 'Email', 'Auftragsbestätigung #4022'),
(2, DATE('now', '-25 days'), 'Meeting', 'Q3 Review & Pricing'),
(3, DATE('now', '-240 days'), 'Email', 'Reklamation defekte Charge'); -- Zombie Alarm!