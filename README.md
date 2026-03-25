# Public Transit System
This high-performance data engineering project features a custom ETL pipeline in C and a relational analytical engine in MySQL. The system ingests raw transit data, simulates operational variability, and supports complex network analysis.

System Architecture

The project is divided into three distinct layers:

1. Ingestion Layer (C): A systems-level parser reads raw CSV data, sanitizes strings, and resolves data inconsistencies.
2. Database Layer (SQL): The relational schema is optimized with foreign key constraints and indexed lookups for efficient transit schedule management.
3. Analytical Layer (SQL): This layer includes complex queries for pathfinding and bottleneck detection within the transit network.

Key Technical Features
- Automated Data Ingestion and Sanitization: The C-based engine uses strtok_r for thread-safe memory management. It detects missing values in the source CSV and converts them to SQL NULL types to ensure database integrity.

- Stochastic Delay Simulation: To simulate real-world service variability, the C-engine implements a randomized delay injection algorithm. During ingestion, the system has a 20% chance of adding a 2-minute "maintenance delay" to arrival timestamps, testing its ability to process non-linear schedule data.

- Relational Graph Analysis: The analytical suite uses multi-table INNER JOINs and subqueries to resolve paths across the transit network. It identifies "Hub" stations where multiple routes intersect, enabling multi-leg journey planning.
