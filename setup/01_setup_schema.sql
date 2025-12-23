-- 1. Tabelle: Stammdaten Artikel (Material Master)
CREATE TABLE artikel (
    mat_nr INTEGER PRIMARY KEY,
    bezeichnung TEXT,
    kategorie TEXT,
    preis_eur REAL,
    sicherheitsbestand INTEGER
);

-- 2. Tabelle: Warenbewegungen (Transaction Data)
CREATE TABLE bewegungen (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    mat_nr INTEGER,
    buchungsdatum DATE,
    bewegungstyp TEXT, -- 'WE' (Wareneingang) oder 'WA' (Warenausgang)
    menge INTEGER,
    lagerort TEXT,
    user_id TEXT
);