# ⚙️ SQL Query Execution Order & Logic

Unlike procedural languages (Python), SQL is declarative. Understanding the internal **Order of Execution** is critical for performance optimization and debugging complex joins.

This document serves as a reference for the logical processing steps within the pipeline.

## The 8 Stages of Processing

| Step | Operation | System Logic | Logistics Analogy 🚚 |
| :--- | :--- | :--- | :--- |
| **1.** | `FROM` & `JOIN` | **Data Ingestion:** Identifies sources and performs Cartesian products/Joins. | **Inbound Dock:** All pallets are unloaded into the staging area. |
| **2.** | `WHERE` | **Row-Level Filtering:** Discards non-compliant rows *before* aggregation to save memory. | **Quality Gate:** Damaged goods are rejected immediately. |
| **3.** | `GROUP BY` | **Aggregation:** Collapses rows into buckets based on dimensions. | **Consolidation:** Items are sorted into specific bins/zones. |
| **4.** | `HAVING` | **Group-Level Filtering:** Removes entire buckets based on aggregate conditions (e.g., `SUM(qty) < 0`). | **Weight Check:** "Pallets under 50kg are rejected." |
| **5.** | `SELECT` | **Projection & Calculation:** Derives columns, applies Window Functions (`RANK`, `NTILE`). | **Labeling:** Final barcodes and price tags are applied. |
| **6.** | `DISTINCT` | **Deduplication:** Removes redundant rows from the result set. | **Manifest Cleanup:** Removing duplicate entries from the delivery note. |
| **7.** | `ORDER BY` | **Sorting:** Arranges the final dataset for presentation. | **Loading Sequence:** Pallets are arranged for the truck route (LIFO/FIFO). |
| **8.** | `LIMIT` | **Pagination:** Restricts the output size. | **Cut-Off:** "Only ship the first 10 pallets today." |

---

### 💡 Architectural Note: "Scope Visibility"

A common pitfall in SQL modeling is attempting to use an **Alias** defined in `SELECT` within the `WHERE` clause.
* **Why it fails:** `WHERE` (Step 2) happens *before* `SELECT` (Step 5).
* **Solution:** Use Common Table Expressions (CTEs) or nested queries to materialize the alias first.