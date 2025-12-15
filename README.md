# Inventory Management & SQL Pipeline 🚛

## Overview
This project simulates a **Logistics Warehouse Management System (WMS)** using **SQLite** and **Python**. It demonstrates the end-to-end workflow of a Data Analyst:
1.  **Data Modeling:** Creating a relational database schema for articles and movements.
2.  **SQL Analysis:** Performing complex Joins, Aggregations, and Window Functions to determine stock levels and values.
3.  **Python Integration:** Extracting data via `sqlite3` into **Pandas** for automated reporting (e.g., Reorder Alarms).

## Business Case
In manual logistics environments, "Stockouts" (OOS) are a major risk. This tool automates the detection of critical stock levels by comparing current inventory (calculated from transaction history) against safety stock levels defined in master data.

## Tech Stack
* **Database:** SQLite (Relational DB)
* **Language:** SQL (Aggregations, Joins, Having-Clauses)
* **Analysis:** Python (Pandas)
* **Tooling:** DBeaver, VS Code

## How to use
1.  Run the SQL scripts in `/sql` to generate the database.
2.  Run `src/db_connection.py` to generate the Critical Stock Report.