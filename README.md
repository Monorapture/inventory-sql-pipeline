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
