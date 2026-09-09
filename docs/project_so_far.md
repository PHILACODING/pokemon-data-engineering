# 🚀 Pokémon Data Engineering Project — Project So Far

## 📌 Project Overview

This project is an end-to-end data engineering pipeline built around the free **PokéAPI**.

The objective is to demonstrate the complete journey of data from an external REST API through Python extraction, data transformation, PostgreSQL storage, SQL analytics, and Power BI reporting.

The project is being developed using a professional data-engineering repository structure with separation between raw data, processed data, source code, SQL, tests, documentation, and reporting.

---

# 🏗️ Current Architecture

```text
PokéAPI
   ↓
Python API Extraction
   ↓
Raw CSV
   ↓
Pandas Profiling & Transformation
   ↓
Processed CSV
   ↓
PostgreSQL
   ↓
ETL Validation
   ↓
SQL Analytical Queries
   ↓
pokemon_powerbi VIEW
   ↓
Power BI
   ↓
Interactive Dashboard
```

---

# 📁 Project Structure

```text
pokemon-data-engineering/
│
├── .venv/
├── .gitignore
├── .env.example
├── README.md
├── requirements.txt
│
├── data/
│   ├── raw/
│   │   └── pokemon_raw.csv
│   ├── processed/
│   │   └── pokemon_clean.csv
│   └── README.md
│
├── notebooks/
│   └── pokemon_analysis.ipynb
│
├── src/
│   └── pokemon_pipeline/
│       ├── __init__.py
│       ├── extraction/
│       │   ├── __init__.py
│       │   └── api_json.py
│       ├── transformation/
│       │   ├── __init__.py
│       │   └── transform.py
│       ├── loading/
│       │   ├── __init__.py
│       │   └── pokemon_load.py
│       └── validation/
│           ├── __init__.py
│           └── validate.py
│
├── sql/
│   ├── 01_database_setup.sql
│   ├── 02_schema.sql
│   ├── 03_validation.sql
│   └── 04_analysis.sql
│
├── tests/
│   ├── __init__.py
│   ├── test_extraction.py
│   ├── test_transformation.py
│   └── test_validation.py
│
├── docs/
│   ├── architecture.md
│   ├── data_dictionary.md
│   └── project_so_far.md
│
└── reports/
    └── figures/
```

---

# 1. API Extraction — ✅ COMPLETED

Data is extracted from the free PokéAPI REST API using Python.

The API returned:

```text
1351 Pokémon records
```

The initial extracted dataset contained 13 fields:

```text
id
name
height
weight
base_experience
types
abilities
hp
attack
defense
special_attack
special_defense
speed
```

The raw API data is saved to:

```text
data/raw/pokemon_raw.csv
```

The extraction process demonstrates:

* REST API requests
* JSON responses
* Python dictionaries
* Python lists
* API pagination/list retrieval
* Structured raw-data storage

---

# 2. Pandas Data Profiling & Transformation — ✅ COMPLETED

The raw CSV was loaded into Pandas for profiling, cleaning, validation and transformation.

Initial dataset:

```text
Rows:    1351
Columns: 13
```

Feature engineering added:

```text
type_count
ability_count
```

Final transformed dataset:

```text
Rows:    1351
Columns: 15
```

The transformation stage included:

* DataFrame inspection
* Data-type inspection
* Missing-value analysis
* Duplicate detection
* Numeric validation
* List normalization
* Feature engineering
* Exploratory data analysis

---

# 3. Missing-Value Analysis — ✅ COMPLETED

Only one field contains missing values:

```text
base_experience
```

Results:

```text
Missing records: 49
Missing percentage: 3.63%
```

The PokéAPI was checked directly to confirm that these values originate from the source API.

Decision:

```text
Preserve the missing values.
```

The values remain:

```text
Pandas → NaN
PostgreSQL → NULL
```

No artificial values were inserted.

This demonstrates an important data-engineering principle:

> Missing source data should not automatically be replaced with invented values.

---

# 4. Duplicate Analysis — ✅ COMPLETED

Duplicate checks produced:

```text
Full duplicate rows:       0
Duplicate Pokémon IDs:     0
Duplicate Pokémon names:   0
```

All 1,351 Pokémon records have unique IDs and names.

---

# 5. Numeric Data Validation — ✅ COMPLETED

Numeric attributes were checked for invalid values.

Results:

```text
Zero/negative heights: 0
Negative weights:      0
```

One record has a source-provided weight of:

```text
0
```

This belongs to:

```text
eternatus-eternamax
```

The value was investigated and preserved rather than incorrectly modifying source data.

PokéAPI units:

```text
height → decimetres
weight → hectograms
```

Legitimate extreme values were also preserved.

---

# 6. List/Data Normalization — ✅ COMPLETED

The API contains nested list data in:

```text
types
abilities
```

When stored in CSV, these lists become strings such as:

```text
"['grass', 'poison']"
```

Python's:

```python
ast.literal_eval()
```

was used to safely convert these strings back into Python lists.

The lists were then normalized into separate PostgreSQL relationship tables.

This avoids storing multiple values inside a single relational database field.

---

# 7. Pokémon Type Analysis — ✅ COMPLETED

Type analysis produced:

```text
Total type assignments: 2116
Single-type Pokémon:     586
Dual-type Pokémon:       765
```

The most common types included:

```text
water       192
normal      160
grass       156
flying      154
psychic     142
dragon      117
electric    114
fire        109
fighting    109
poison      106
```

Pandas techniques such as:

```python
df["types"].explode().value_counts()
```

were used to flatten nested lists for analysis.

---

# 8. Pokémon Ability Analysis — ✅ COMPLETED

The dataset contains:

```text
Distinct abilities: 313
Total ability assignments: 2941
```

Ability distribution:

```text
3 abilities → 613 Pokémon
2 abilities → 375 Pokémon
1 ability   → 352 Pokémon
0 abilities → 11 Pokémon
```

The most common abilities include:

```text
swift-swim
sturdy
intimidate
levitate
keen-eye
```

The 11 records with empty ability lists were checked against the PokéAPI and preserved as legitimate source data.

In PostgreSQL, these Pokémon simply have no corresponding rows in:

```text
pokemon_abilities
```

---

# 9. Clean Dataset — ✅ COMPLETED

The transformed dataset was saved as:

```text
data/processed/pokemon_clean.csv
```

At this point the project had successfully progressed from:

```text
API → Raw CSV → Pandas → Clean CSV
```

---

# 10. PostgreSQL Database — ✅ COMPLETED

A PostgreSQL database was created:

```text
pokemon_data
```

The relational model contains three main tables.

## pokemon

Stores one record per Pokémon.

```text
id
name
height
weight
base_experience
hp
attack
defense
special_attack
special_defense
speed
type_count
ability_count
```

Primary key:

```text
id
```

## pokemon_types

Stores Pokémon-to-type relationships.

```text
pokemon_id
type
```

Composite primary key:

```text
(pokemon_id, type)
```

Foreign key:

```text
pokemon_id → pokemon.id
```

## pokemon_abilities

Stores Pokémon-to-ability relationships.

```text
pokemon_id
ability
```

Composite primary key:

```text
(pokemon_id, ability)
```

Foreign key:

```text
pokemon_id → pokemon.id
```

Indexes were created for:

```text
pokemon_types(type)
pokemon_abilities(ability)
```

---

# 11. Python → PostgreSQL ETL — ✅ COMPLETED

A Python PostgreSQL loader was implemented.

The loader successfully transfers the processed dataset into PostgreSQL.

Expected and loaded records:

```text
pokemon:           1351
pokemon_types:     2116
pokemon_abilities: 2941
```

Missing `base_experience` values:

```text
49
```

The loader also converts Pandas `NaN` values into Python `None`, allowing PostgreSQL to store them as SQL `NULL`.

The loading process was designed to be safely rerunnable during development.

---

# 12. PostgreSQL ETL Validation — ✅ COMPLETED

The PostgreSQL database passed the project's validation checks.

Validation covered:

* Row counts
* Duplicate IDs
* Duplicate names
* Foreign-key integrity
* Orphan records
* Type-count consistency
* Ability-count consistency
* Missing `base_experience`
* Invalid statistics
* Invalid measurements
* Overall ETL consistency

Final validation results:

```text
pokemon rows:             1351
pokemon_types rows:       2116
pokemon_abilities rows:   2941
NULL base_experience:       49
duplicate IDs:                0
orphan records:               0
invalid statistics:            0
invalid measurements:         0
```

The validation stage acts as a **data-quality gate** between ETL loading and analytical SQL.

---

# 13. SQL Analytical Analysis — ✅ COMPLETED

A dedicated analytical SQL script was created:

```text
sql/04_analysis.sql
```

The project contains 15 analytical SQL queries.

The analysis covers:

1. Pokémon type distribution
2. Top Pokémon by total base stats
3. Most common Pokémon abilities
4. Average combat statistics by type
5. Single-type vs dual-type analysis
6. Highest individual combat statistics
7. Highest base-experience Pokémon
8. Attack and defense ranking
9. Average total statistics by type
10. Strongest Pokémon within each type
11. Fastest Pokémon
12. Top 3 Pokémon within each type
13. Average statistics by type category
14. Most common dual-type combinations
15. Abilities by average total statistics

SQL techniques demonstrated include:

```text
SELECT
JOIN
GROUP BY
HAVING
CASE
CTEs
Window Functions
Aggregations
Subqueries
ORDER BY
LIMIT
UNION ALL
PARTITION BY
ROW_NUMBER()
```

The objective is to demonstrate practical analytical SQL rather than only basic queries.

---

# 14. Power BI SQL View — ✅ COMPLETED

A dedicated PostgreSQL view was created for Power BI:

```text
pokemon_powerbi
```

The view exposes the main Pokémon attributes and calculates:

```text
total_stats
```

where:

```text
total_stats =
hp
+ attack
+ defense
+ special_attack
+ special_defense
+ speed
```

This provides Power BI with a clean analytical dataset without creating a second physical copy of the underlying Pokémon data.

---

# 15. Power BI Connection — ✅ COMPLETED

Power BI Desktop has been successfully connected to:

```text
PostgreSQL
    ↓
pokemon_data
    ↓
public
    ↓
pokemon_powerbi
```

The following PostgreSQL objects are visible in Power BI:

```text
public pokemon
public pokemon_abilities
public pokemon_powerbi
public pokemon_types
```

The main Power BI dataset currently being used is:

```text
public pokemon_powerbi
```

---

# 16. Power BI Dashboard — 🔄 IN PROGRESS

The Power BI dashboard has officially started.

## Visual 1 — Total Pokémon

A Card visual was created using the Pokémon ID count.

Result:

```text
1,351 Pokémon
```

## Visual 2 — Pokémon Count by Type

A clustered column chart was created using:

```text
pokemon_types.type
```

and the count of:

```text
pokemon_id
```

This visual displays the number of Pokémon associated with each type.

## Visual 3 — Top Pokémon by Total Stats

Currently being built.

The planned visual uses:

```text
name
total_stats
```

and will rank Pokémon by their combined combat statistics.

---

# 17. Git & GitHub — ✅ CURRENTLY SYNCED

The project is maintained using Git.

Recent commits include:

```text
ce8a6b4 refactor: restructure project into data engineering layout

1041d4f fix: save extracted data to raw data directory

3746f6f chore: finalize ETL validation and loading paths

b80cef4 feat: add Pokemon SQL analysis queries
```

The latest changes have been pushed successfully to:

```text
https://github.com/PHILACODING/pokemon-data-engineering
```

Current Git state:

```text
Branch: main
Working tree: clean
Remote: synchronized
```

---

# 📊 Current Project Status

```text
API extraction                 ✅ COMPLETE
Raw CSV                        ✅ COMPLETE
Pandas profiling               ✅ COMPLETE
Data cleaning                  ✅ COMPLETE
Feature engineering            ✅ COMPLETE
EDA                            ✅ COMPLETE
Type analysis                  ✅ COMPLETE
Ability analysis               ✅ COMPLETE
Clean CSV                      ✅ COMPLETE
PostgreSQL database            ✅ COMPLETE
Relational data model          ✅ COMPLETE
Indexes                        ✅ COMPLETE
Python PostgreSQL loader       ✅ COMPLETE
PostgreSQL ETL load            ✅ COMPLETE
PostgreSQL validation          ✅ COMPLETE
SQL analytical queries         ✅ COMPLETE
Power BI SQL view              ✅ COMPLETE
Power BI connection            ✅ COMPLETE
Power BI dashboard             🔄 IN PROGRESS
Power BI visuals               🔄 IN PROGRESS
Final documentation            ⏳ NEXT
Python automated tests         ⏳ NEXT
GitHub portfolio polish        🔄 IN PROGRESS
```

---

# 🧠 Engineering Lessons Learned

This project has covered:

* REST API data extraction
* JSON structures
* Python dictionaries
* Python lists
* Pandas DataFrames
* Data profiling
* Missing-value analysis
* Duplicate detection
* Data validation
* Feature engineering
* List normalization
* Relational database design
* Primary keys
* Composite primary keys
* Foreign keys
* Cascading deletes
* Database indexes
* Python/PostgreSQL integration
* Transactions
* Commit and rollback
* ETL pipeline design
* Rerunnable ETL loads
* Referential integrity
* SQL analytical workflows
* JOIN operations
* Aggregations
* GROUP BY
* HAVING
* CASE statements
* CTEs
* Window functions
* Subqueries
* Data-quality gates
* PostgreSQL views
* Preparing relational data for BI
* Power BI reporting
* Git/GitHub workflow
* Professional project structure

---

# 🎯 Next Steps

The immediate priority is to complete the Power BI dashboard.

```text
Power BI Dashboard
       ↓
Dashboard validation
       ↓
Python automated tests
       ↓
Final documentation
       ↓
Architecture documentation
       ↓
Data dictionary
       ↓
README improvements
       ↓
Screenshots
       ↓
GitHub portfolio polish
```

The next Power BI task is:

```text
Top Pokémon by Total Stats
```

After the dashboard is complete, the project will move toward final documentation, testing and portfolio presentation.

---

# 🏁 End-to-End Progress

The project has successfully progressed through the core data-engineering pipeline:

```text
             ┌─────────────┐
             │   PokéAPI   │
             └──────┬──────┘
                    ↓
             ┌─────────────┐
             │   Python    │
             │ Extraction  │
             └──────┬──────┘
                    ↓
             ┌─────────────┐
             │  Raw CSV    │
             └──────┬──────┘
                    ↓
             ┌─────────────┐
             │   Pandas    │
             │ Transform   │
             └──────┬──────┘
                    ↓
             ┌─────────────┐
             │ Processed   │
             │    CSV      │
             └──────┬──────┘
                    ↓
             ┌─────────────┐
             │ PostgreSQL  │
             └──────┬──────┘
                    ↓
             ┌─────────────┐
             │ ETL Quality │
             │    Gate     │
             └──────┬──────┘
                    ↓
             ┌─────────────┐
             │ SQL Analysis│
             └──────┬──────┘
                    ↓
             ┌─────────────┐
             │  Power BI   │
             └──────┬──────┘
                    ↓
             ┌─────────────┐
             │  Dashboard  │
             └─────────────┘
```

The core **API → Python → Pandas → PostgreSQL → SQL → Power BI** pipeline is now operational. The remaining work is primarily dashboard completion, testing, documentation and portfolio polish.
