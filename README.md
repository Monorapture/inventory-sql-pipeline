<<<<<<< HEAD
# 📦 Automated Inventory Risk Pipeline

**A resilient ELT pipeline designed to detect stockouts and optimize capital allocation in warehouse environments.**

![Status](https://img.shields.io/badge/Status-Production%20Ready-green)
![Tech](https://img.shields.io/badge/Stack-Python%20%7C%20SQL%20%7C%20Pandas-blue)

## 🚀 Business Case
In high-frequency logistics, "Stockouts" (OOS) directly translate to lost revenue and stalled production lines. 
This project moves away from manual Excel handling to an **automated Data Engineering solution**.

It answers two critical questions:
1.  **Risk Management:** Which items are currently below the safety stock threshold?
2.  **Capital Commitment:** How much capital is tied up in specific storage locations ("Dead Stock Analysis")?

## 🏗️ Architecture

The system follows a modern **ELT (Extract, Load, Transform)** pattern with clear separation of concerns:

```mermaid
graph LR
A[Raw Data / ERP] -->|Ingest| B(SQLite Database)
B -->|dbt-style Modeling| C{SQL Views / Marts}
C -->|Extract & Enrich| D[Python Orchestrator]
D -->|Generate| E[Excel Reports for Procurement]

Key Components

    setup/ (Infrastructure): Defines the physical schema (DDL) and seeds mock data for testing.

    models/intermediate/ (Logic): Centralized logic layer (int_inventory_levels) acting as the Single Source of Truth.

    models/marts/ (Reporting): Business-specific queries (e.g., alert_reorder.sql) consuming the intermediate layer.

    scripts/ (Orchestration): Python scripts handling the DB connection, transformation (Pandas), and report generation.

🛠️ Installation & Usage
1. Prerequisites

    Python 3.10+

    SQLite3

2. Setup Infrastructure

Initialize the database schema and load dummy data:
Bash

# Clean install of the database (Tables & Data)
# Open DBeaver or run via CLI
sqlite3 data/logistik_playground.db < setup/01_setup_schema.sql
sqlite3 data/logistik_playground.db < setup/02_insert_dummy_data.sql

3. Deploy Business Logic

Deploy the View Layer (Schema Migration):
Bash

python scripts/init_db_views.py

4. Run the Pipeline

Generate the daily risk report:
Bash

python scripts/db_connection.py

Output: reports/dispo_bericht.xlsx will be generated.
📈 Key Learnings & Patterns

    Idempotency: Scripts can be re-run multiple times without causing data duplication or crashes (DROP VIEW IF EXISTS).

    Modularization: Business logic is decoupled from the execution layer.

    Physical Grounding: Data constraints reflect physical realities (e.g., distinct storage locations).
=======
# 🚛 Inventory Analytics Pipeline

![Status](https://img.shields.io/badge/Status-Active-success?style=flat-square)
![Python](https://img.shields.io/badge/Python-3.10+-blue?style=flat-square&logo=python&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-SQLite-orange?style=flat-square&logo=sqlite&logoColor=white)
![Architecture](https://img.shields.io/badge/Architecture-Modular_ELT-purple?style=flat-square)

## 📖 Overview
This project is more than just a stock calculator. It implements a **Modular Analytics Engineering Pipeline** for logistics data.
Instead of monolithic SQL scripts, it follows **Modern Data Stack principles** (inspired by dbt) to separate **Data Cleaning** from **Business Logic**.

It answers critical supply chain questions:
* **Where is capital tied up?** (Inventory Value Analysis)
* **What needs to be reordered?** (Stockout Risk & Reorder Alarms)
* **Which data is "dead"?** (Zombie Data Detection)

---

## 🏗️ Architecture & Design Pattern
The project moves away from "Spaghetti SQL" to a layered **Clean Architecture**:

1.  **Raw Layer (`setup/`)**
    Defines the physical schema (Tables: `artikel`, `bewegungen`) and handles initial data ingestion.

2.  **Intermediate Layer (`models/intermediate/`)**
    Centralizes logic! A **View** (`int_inventory_levels`) calculates stock levels *once* to serve as a "Single Source of Truth". This prevents logic drift between different reports.

3.  **Marts Layer (`models/marts/`)**
    Business-specific reports (e.g., `alert_reorder.sql`) that consume the intermediate layer to answer specific business questions.

4.  **Application Layer (`scripts/`)**
    Python automates the orchestration—building views, running queries, and generating user-friendly Excel reports with auto-scaling.

---

## 📂 Project Structure

```text
inventory-sql-pipeline/
│
├── 📂 setup/                   # Infrastructure as Code (Schema & Dummy Data)
│   ├── 01_setup_schema.sql
│   └── 02_insert_dummy_data.sql
│
├── 📂 models/                  # The "Brain" of the system (ELT Logic)
│   ├── 📂 intermediate/        # Logic Layer (Views / Pre-Calculation)
│   │   └── int_inventory_levels.sql
│   └── 📂 marts/               # Business Layer (Ready-to-use Reports)
│       ├── report_lagerwert.sql
│       └── alert_reorder.sql
│
├── 📂 scripts/                 # Python Automation & Orchestration
│   ├── init_db_views.py        # Builds the database views (Architecture)
│   └── db_connection.py        # Generates the reports (Application)
│
├── 📂 data/                    # SQLite Database (Local storage)
└── 📂 reports/                 # Generated Excel Output (Business Value)

```
## 🚀 How to Run

This pipeline is designed to be **idempotent** (you can run it multiple times without breaking the state).

### 1. Initialize Infrastructure
First, create the tables and insert dummy data (simulating an ERP export).
*(Run the SQL files in `setup/` via DBeaver or your SQL client)*.

### 2. Build the Logic Layer
Run the Python script to compile and create the SQL Views in the database.
```bash
python scripts/init_db_views.py
```
>>>>>>> 08613e8a367d83026b855b6e75798b02d348d054
