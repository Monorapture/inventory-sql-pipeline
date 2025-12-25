/* ---------------------------------------------------------------------------
   FILE: setup/01_setup_schema.sql
   TYPE: Infrastructure as Code (DDL)
   DESCRIPTION: 
     Defines the physical database schema for the WMS (Warehouse Management System).
     
     SCHEMA ARCHITECTURE:
     1. Master Data (Stammdaten): 'artikel', 'lieferanten'
     2. Transaction Data (Bewegungsdaten): 'bewegungen', 'kommunikation'
   ---------------------------------------------------------------------------
*/

-- ===================================================
-- 1. MASTER DATA (ENTITY DEFINITIONS)
-- ===================================================

-- Table: Article Master
-- Contains static attributes for materials (SKUs).
DROP TABLE IF EXISTS artikel;
CREATE TABLE artikel (
    mat_nr INTEGER PRIMARY KEY,          -- Unique Material ID
    bezeichnung TEXT NOT NULL,           -- Description
    kategorie TEXT,                      -- Material Group (e.g., 'Electronics')
    preis_eur REAL,                      -- Unit Cost
    sicherheitsbestand INTEGER,          -- Safety Stock Threshold (Critical for Alerts)
    lieferanten_id INTEGER,              -- FK: Link to Supplier
    FOREIGN KEY(lieferanten_id) REFERENCES lieferanten(lieferanten_id)
);

-- Table: Supplier Master (CRM)
-- Added to track supplier performance and relationship status.
DROP TABLE IF EXISTS lieferanten;
CREATE TABLE lieferanten (
    lieferanten_id INTEGER PRIMARY KEY AUTOINCREMENT,
    firmen_name TEXT NOT NULL,
    stadt TEXT,
    rating INTEGER CHECK(rating BETWEEN 1 AND 5) -- Constraint: 1=Bad, 5=Excellent
);


-- ===================================================
-- 2. TRANSACTION DATA (EVENT LOGS)
-- ===================================================

-- Table: Goods Movements
-- Logs every physical change in stock (Inbound/Outbound).
DROP TABLE IF EXISTS bewegungen;
CREATE TABLE bewegungen (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    mat_nr INTEGER,                      -- FK: Link to Article
    buchungsdatum DATE DEFAULT CURRENT_DATE,
    bewegungstyp TEXT,                   -- 'WE' (Inbound), 'WA' (Outbound)
    menge INTEGER,                       -- Positive or Negative Quantity
    lagerort TEXT,                       -- Storage Bin Location
    user_id TEXT,                        -- Auditor/Worker ID
    FOREIGN KEY(mat_nr) REFERENCES artikel(mat_nr)
);

-- Table: Communication Log
-- Tracks interaction history for "Zombie Supplier" analysis.
DROP TABLE IF EXISTS kommunikation;
CREATE TABLE kommunikation (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    lieferanten_id INTEGER,
    datum DATE DEFAULT CURRENT_DATE,
    kanal TEXT,                          -- e.g., 'Email', 'Phone'
    betreff TEXT,
    FOREIGN KEY(lieferanten_id) REFERENCES lieferanten(lieferanten_id)
);