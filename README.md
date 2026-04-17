# Public Transit System

> A full-cycle ETL pipeline for public transit data, built with a high-performance C ingestion engine, a normalized PostgreSQL relational schema, and Python-powered visual analytics.

---

## What It Does

This project recreates how a real transit system works behind the scenes.
It starts with raw schedule data in CSV files, which is pulled into a C-based processing engine. There, the data is cleaned up, reshaped, and loaded into a normalized PostgreSQL database. On top of that, a set of SQL queries is used to find major hub stations, follow routes across the network, and spot where schedules tend to break down.

To make things more realistic, a stochastic delay simulation injects variability into arrival times, and a Python script generates a heatmap that shows where delays cluster across the system.

The idea was to build something that actually resembles a transit authority’s backend with intentional design choices at every layer.

---

## Architecture

```
Raw CSV Data (data/)
        │
        ▼
C Ingestion Engine (src/ & scripts/)
  ├── CSV Parsing (strtok_r, thread-safe)
  ├── Data Sanitization (NULL handling, type coercion)
  └── Stochastic Delay Simulation (20% chance, +2 min)
        │
        ▼
PostgreSQL Database (sql/)
  ├── Normalized Schema (routes, stops, schedules)
  ├── Foreign Key Constraints
  └── Indexed Lookups
        │
        ▼
Python Analytics Layer
  └── Delay Heatmap Visualization (delay_heatmap.png)
```

---

## Stack

| Layer | Technology |
|---|---|
| **Ingestion Engine** | C (GCC), libpq (PostgreSQL C Client Library) |
| **Database** | PostgreSQL with normalized relational schema |
| **Build System** | Make (automated compilation + library linking) |
| **Analytics & Visualization** | Python, Matplotlib / Seaborn |
| **Data Format** | CSV (raw input), SQL (structured output) |

---

## Key Features

- **High-Performance C Ingestion** — The core ETL engine is written in C for speed and control. It uses `strtok_r` for thread-safe CSV tokenization and handles manual memory management to process large transit datasets efficiently.
- **Data Sanitization at Ingestion** — Dirty input data (type mismatches, missing fields) is resolved during the ingestion phase itself, converting invalid values to SQL-compatible `NULL` types before they reach the database. 100% of data type inconsistencies are handled at the boundary.
- **Stochastic Delay Simulation** — A probabilistic algorithm introduces a 20% chance of a 2-minute delay to arrival times, mimicking real transit variability. This tests the pipeline's ability to handle non-linear, non-deterministic schedule data.
- **Normalized Relational Schema** — The database is designed with proper normalization, foreign key constraints, and indexed columns to maintain referential integrity and query performance as data volume grows.
- **Hub Station Analysis** — Multi-table `INNER JOIN`s and aggregation queries identify stations where multiple routes intersect — the "hubs" that are most critical (and most vulnerable) in the network.
- **Delay Heatmap** — A Python visualization layer reads from the processed data and generates a spatial heatmap of delay clusters, making the simulation output interpretable at a glance.

---

## Project Structure

```
PublicTransitSystem/
├── src/                    # C source files — core ingestion engine logic
├── scripts/                # Supporting C scripts for data processing
├── sql/
│   ├── schema.sql          # Table definitions — routes, stops, schedules
│   └── queries.sql         # Analytical queries — joins, aggregations, pathfinding
├── data/                   # Landing zone for raw CSV transit data
├── delay_heatmap.png       # Output visualization of delay distribution
├── Makefile                # Compilation automation + libpq linking
└── requirements.txt        # Python dependencies for analytics layer
```

---

## Getting Started

### 1. Build the C Ingestion Engine

```bash
make
```

This compiles the C source files and links the PostgreSQL client library (`libpq`). The resulting binary is ready to process CSV data.

### 2. Set Up the Database

Connect to your PostgreSQL instance and run the schema script:

```bash
psql -U your_user -d transit_db -f sql/schema.sql
```

### 3. Run the Ingestion Pipeline

```bash
./transit_ingest data/your_transit_data.csv
```

The engine will parse, sanitize, apply the delay simulation, and load records into the database.

### 4. Run Analytical Queries

```bash
psql -U your_user -d transit_db -f sql/queries.sql
```

### 5. Generate the Delay Heatmap

```bash
pip install -r requirements.txt
python visualize_delays.py
```

Output: `delay_heatmap.png` — a visual breakdown of delay distribution across the transit network.

---

## The Delay Simulation

The stochastic delay algorithm reflects a real design challenge in transit data systems: arrival times are not deterministic. Rather than using clean, uniform data, the pipeline intentionally introduces noise:

```c
// 20% probability of a 2-minute delay
if ((rand() % 100) < 20) {
    arrival_time += 2;
}
```

This tests that the downstream schema and queries handle irregular, non-linear schedule data correctly — the same kind of variability that real GTFS feeds and transit APIs produce.

---

## SQL Design Highlights

The schema enforces data integrity through foreign keys between `routes`, `stops`, and `schedules`. Example of the hub station query — identifying stops where multiple routes intersect:

```sql
SELECT
    s.stop_name,
    COUNT(DISTINCT r.route_id) AS route_count
FROM stops s
INNER JOIN schedules sch ON s.stop_id = sch.stop_id
INNER JOIN routes r ON sch.route_id = r.route_id
GROUP BY s.stop_name
HAVING route_count > 1
ORDER BY route_count DESC;
```

This kind of query is what a transit planner would actually run to find network vulnerabilities or plan service changes.

---

## What I Learned Building This

- **C is unforgiving, which is the point.** There's no garbage collector and no helpful error messages when memory goes wrong. Learning to use `strtok_r` instead of `strtok` — and understanding *why* the thread-safe version matters — was one of those lessons that doesn't come from reading documentation.
- **Data quality is an ingestion problem, not a query problem.** It's tempting to clean data with SQL after it lands. But fixing type mismatches and nulls at the C layer, before anything hits the database, means every query downstream can trust what it's reading. That's a much more defensible architecture.
- **Normalization has a performance cost that's worth paying.** Splitting routes, stops, and schedules into separate tables means more joins, but it also means you can update a route name in one place instead of hundreds of rows. That tradeoff becomes obvious quickly when you're writing queries across a real network.

---

## Skills Demonstrated

- **Systems Programming** — C, manual memory management, thread-safe string parsing, libpq (PostgreSQL C Client Library)
- **Database Engineering** — Normalized schema design, foreign key constraints, indexed query optimization, PostgreSQL
- **ETL Pipeline Design** — Multi-stage data flow from raw CSV through transformation to structured relational storage
- **Data Simulation** — Probabilistic modeling of real-world variability in schedule data
- **SQL Analytics** — Multi-table joins, subqueries, aggregations, hub/pathfinding analysis
- **Build Automation** — Makefile-driven compilation and library linking
