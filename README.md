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

🚀 How to Run

This pipeline is designed to be idempotent (you can run it multiple times without breaking the state).
1. Initialize Infrastructure

First, create the tables and insert dummy data (simulating an ERP export). (Run the SQL files in setup/ via DBeaver or your SQL client).
2. Build the Logic Layer

Run the Python script to compile and create the SQL Views in the database.
Bash

python scripts/init_db_views.py

    Output: ✅ ERFOLG: View 'int_inventory_levels' wurde erstellt...

3. Generate Reports

Run the main application to extract data and build the Excel report.
Bash

python scripts/db_connection.py

    Output: ✅ Report erfolgreich gespeichert (mit Autoscale): reports/dispo_bericht.xlsx

🛠️ Tech Stack

    Core: Python (Pandas, OpenPyXL), SQLite3

    Concept: ELT (Extract, Load, Transform) via SQL Views

    Tooling: VS Code, DBeaver

    Key Libraries: pandas, openpyxl

👨‍💻 About

Built by Kilian Sender (Logistics Data Analyst & Systems Thinker). Focusing on bridging the gap between physical operations (Warehouse) and abstract data architecture (Code).

    "The Industrial Master knows how the process works. The Data Architect knows why it breaks. I do both."
