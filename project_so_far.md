# Pokémon End-to-End Data Engineering Project — Progress So Far

## Project Overview

This project is an end-to-end data engineering and analytics pipeline using the free PokéAPI.

The goal is to demonstrate the complete workflow from API data extraction through Python transformation, PostgreSQL data modeling and SQL analysis, and finally Power BI visualization.

The project is being built as a production-style portfolio project, with emphasis on:

* Data extraction
* Data profiling
* Data quality validation
* Data transformation
* Relational data modeling
* ETL pipeline development
* SQL analytics
* Business intelligence visualization
* Reproducibility
* Git/GitHub documentation

## Architecture

```text
PokéAPI
   ↓
Python Requests
   ↓
JSON Response
   ↓
Python List of Dictionaries
   ↓
Pandas DataFrame
   ↓
pokemon_raw.csv
   ↓
Jupyter Notebook
   ↓
Pandas + NumPy Profiling / Cleaning / Transformation / EDA
   ↓
pokemon_clean.csv
   ↓
PostgreSQL
   ↓
SQL Analysis
   ↓
Power BI
```

---

# 1. API Extraction — COMPLETED

Created:

```text
api_json.py
```

Used Python `requests` to retrieve Pokémon data from:

```text
https://pokeapi.co/api/v2
```

The extraction retrieved:

* 1,351 Pokémon records
* 13 initial attributes

The extracted attributes were:

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

The raw data was saved to:

```text
pokemon_raw.csv
```

---

# 2. Pandas Data Profiling & Transformation — COMPLETED

Loaded the raw CSV into Pandas and performed data profiling and transformation.

Initial dataset shape:

```text
(1351, 13)
```

Feature engineering added:

```text
type_count
ability_count
```

Final DataFrame shape:

```text
(1351, 15)
```

## Data Types

The final DataFrame contains:

```text
id                   int64
name                 object
height               int64
weight               int64
base_experience    float64
types                object
abilities            object
hp                   int64
attack               int64
defense              int64
special_attack       int64
special_defense      int64
speed                int64
type_count            int64
ability_count         int64
```

Important lesson:

```python
df.columns.dtype
```

returns the dtype of the column-name Index, not the dtype of every DataFrame column.

To inspect actual column data types:

```python
df.dtypes
```

or:

```python
df.info()
```

---

# 3. Missing-Value Analysis — COMPLETED

Only one column contains missing values:

```text
base_experience
```

Missing records:

```text
49
```

Missing percentage:

```text
3.63%
```

The missing values occur in later Pokémon form variants.

The PokéAPI was directly checked to confirm that these missing values originate from the API rather than being caused by the CSV or Pandas processing.

Decision:

```text
Preserve the missing values.
```

In Pandas they remain:

```text
NaN
```

When loaded into PostgreSQL they become:

```text
NULL
```

This preserves the source data rather than incorrectly imputing values that are unavailable from the API.

---

# 4. Duplicate Analysis — COMPLETED

Full duplicate rows:

```text
0
```

Duplicate Pokémon IDs:

```text
0
```

Duplicate Pokémon names:

```text
0
```

All 1,351 Pokémon records have unique IDs and names.

---

# 5. Numeric Data Validation — COMPLETED

Validated the main numeric attributes for invalid values.

Findings:

* No zero/negative Pokémon heights
* No negative Pokémon weights
* One Pokémon has a weight of `0`
* The zero weight belongs to `eternatus-eternamax`
* Extreme values investigated were legitimate Pokémon/form records

Decision:

```text
Do not remove legitimate extreme values.
Do not modify the source-provided zero weight.
```

PokéAPI measurement units:

```text
height → decimetres
weight → hectograms
```

---

# 6. List/Data Normalization Preparation — COMPLETED

The following columns contain multiple values:

```text
types
abilities
```

When saved to CSV, Python lists become strings such as:

```text
"['grass', 'poison']"
```

Used:

```python
ast.literal_eval()
```

to safely convert these strings back into Python lists.

This allowed the data to be normalized into PostgreSQL child tables rather than storing multiple values inside a single relational column.

---

# 7. Pokémon Type Analysis — COMPLETED

Total type assignments:

```text
2116
```

Single-type Pokémon:

```text
586
```

Dual-type Pokémon:

```text
765
```

Most common Pokémon types:

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
bug         106
rock        104
steel        99
dark         99
ghost        96
ground       96
fairy        88
ice          69
```

The analysis used:

```python
df["types"].explode().value_counts()
```

This demonstrated how nested list data can be flattened for analytical purposes.

---

# 8. Pokémon Ability Analysis — COMPLETED

Distinct abilities:

```text
313
```

Most common abilities include:

```text
swift-swim    48
sturdy        48
intimidate    47
levitate      45
keen-eye      43
```

Ability distribution:

```text
3 abilities → 613 Pokémon
2 abilities → 375 Pokémon
1 ability   → 352 Pokémon
0 abilities → 11 Pokémon
```

Total ability assignments:

```text
2941
```

The following 11 records contain empty ability lists:

```text
zygarde-mega
heatran-mega
darkrai-mega
golisopod-mega
magearna-mega
magearna-original-mega
zeraora-mega
tatsugiri-curly-mega
tatsugiri-droopy-mega
tatsugiri-stretchy-mega
baxcalibur-mega
```

The PokéAPI was directly checked to confirm that these records legitimately return empty ability lists.

Decision:

```text
Preserve empty ability lists.
```

In the normalized PostgreSQL model, these Pokémon simply have no corresponding rows in `pokemon_abilities`.

---

# 9. Clean Dataset — COMPLETED

The transformed dataset was saved as:

```text
pokemon_clean.csv
```

Current project files include:

```text
api_json.py
pokemon_analysis.ipynb
pokemon_clean.csv
pokemon_load.py
pokemon_raw.csv
project_plan2.pdf
project_so_far.md
README.md
```

---

# 10. PostgreSQL Database — COMPLETED

PostgreSQL 18.4 is being used as the relational database.

Database:

```text
pokemon_data
```

Schema:

```text
public
```

The database was recreated cleanly during development.

Current database verification:

```sql
SELECT current_database(), current_schema();
```

Result:

```text
pokemon_data | public
```

---

# 11. PostgreSQL Data Model — COMPLETED

The data was normalized into three relational tables.

## Main Table

```sql
pokemon
```

Contains one row per Pokémon.

Columns:

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

## Pokémon Types

```sql
pokemon_types
```

Relationship:

```text
pokemon
   1
   |
   |
   ∞
pokemon_types
```

Primary key:

```text
(pokemon_id, type)
```

Foreign key:

```text
pokemon_id → pokemon.id
```

## Pokémon Abilities

```sql
pokemon_abilities
```

Relationship:

```text
pokemon
   1
   |
   |
   ∞
pokemon_abilities
```

Primary key:

```text
(pokemon_id, ability)
```

Foreign key:

```text
pokemon_id → pokemon.id
```

The resulting relational model separates the many-valued `types` and `abilities` attributes from the main Pokémon entity.

---

# 12. PostgreSQL Indexes — COMPLETED

Created indexes for frequently queried attributes:

```sql
idx_pokemon_types_type
```

on:

```text
pokemon_types(type)
```

and:

```sql
idx_pokemon_abilities_ability
```

on:

```text
pokemon_abilities(ability)
```

These indexes are intended to improve filtering and aggregation queries involving Pokémon types and abilities.

---

# 13. Python → PostgreSQL ETL Load — COMPLETED

Created:

```text
pokemon_load.py
```

Used:

```text
Python
Pandas
psycopg2
PostgreSQL
```

The loader:

1. Reads `pokemon_clean.csv`
2. Converts serialized lists back to Python lists
3. Connects to PostgreSQL
4. Clears existing development data
5. Loads Pokémon records
6. Loads Pokémon-type relationships
7. Loads Pokémon-ability relationships
8. Commits the transaction
9. Rolls back if an error occurs
10. Closes the database connection

The development load uses:

```sql
TRUNCATE TABLE pokemon RESTART IDENTITY CASCADE;
```

This makes the loader safely rerunnable during development.

The loader also converts missing Pandas `NaN` values in `base_experience` into Python `None`, allowing PostgreSQL to store them as SQL `NULL`.

---

# 14. PostgreSQL Load Result — COMPLETED

The ETL load successfully completed.

Output:

```text
Records to load: 1351
Data load completed successfully.
Database connection closed.
```

Therefore:

```text
Python → PostgreSQL
```

is successfully working.

Expected database contents based on the validated source data:

```text
pokemon rows        → 1351
pokemon_types rows  → 2116
pokemon_abilities   → 2941
NULL base_experience → 49
```

---

# 15. PostgreSQL ETL Validation — NEXT

The next immediate task is to validate the PostgreSQL load before beginning analytical SQL.

Validation will check:

* Total Pokémon rows
* Total type relationship rows
* Total ability relationship rows
* Missing `base_experience` values
* Duplicate Pokémon IDs
* Foreign-key integrity
* Orphan type records
* Orphan ability records
* `type_count` against actual type relationships
* `ability_count` against actual ability relationships
* Overall ETL consistency

Expected core validation:

```text
pokemon rows        → 1351
pokemon_types rows  → 2116
pokemon_abilities   → 2941
NULL base_experience → 49
duplicate IDs       → 0
```

The validation stage acts as a quality gate between the ETL load and analytical SQL.

---

# 16. SQL Analysis — NEXT

After ETL validation, the project will move into analytical SQL.

Planned analysis includes:

```text
Pokémon statistics
Type distribution
Ability distribution
Strongest Pokémon by statistics
Average statistics by type
Attack vs defense analysis
Speed analysis
Base experience analysis
Multi-type Pokémon analysis
Top Pokémon by combined statistics
```

SQL will use techniques such as:

```text
JOIN
GROUP BY
HAVING
CASE
CTEs
Window Functions
Aggregations
Subqueries
ORDER BY
```

The goal is to demonstrate production-style analytical SQL rather than only basic `SELECT` queries.

The SQL analysis will also be designed to produce meaningful datasets that can later feed Power BI.

---

# 17. Power BI — FUTURE STAGE

After SQL analysis, the PostgreSQL database will be connected to Power BI.

Planned dashboard areas:

```text
Pokémon Overview
Type Analysis
Combat Statistics
Abilities
Top Pokémon
Statistical Comparisons
```

The Power BI stage will demonstrate the complete analytical path:

```text
API
 ↓
Python
 ↓
Pandas
 ↓
PostgreSQL
 ↓
SQL
 ↓
Power BI
```

---

# 18. Final Documentation & GitHub — FUTURE STAGE

After the technical pipeline is complete, the project will be prepared as a portfolio project.

Planned finalization includes:

```text
README.md
project documentation
architecture diagram
data dictionary
SQL scripts
ETL documentation
Power BI dashboard
screenshots
Git commit history
GitHub repository cleanup
```

Before pushing the project to GitHub, database credentials currently used for local development must be removed from source code.

Credentials should be moved to environment variables or a `.env` file, and `.env` should be added to `.gitignore`.

---

# Current Project Status

```text
API extraction              ✅ COMPLETE
Raw CSV                     ✅ COMPLETE
Pandas profiling            ✅ COMPLETE
Data cleaning               ✅ COMPLETE
Feature engineering        ✅ COMPLETE
EDA                         ✅ COMPLETE
Type analysis               ✅ COMPLETE
Ability analysis            ✅ COMPLETE
Clean CSV                   ✅ COMPLETE
PostgreSQL database         ✅ COMPLETE
Relational data model       ✅ COMPLETE
Indexes                     ✅ COMPLETE
Python PostgreSQL loader    ✅ COMPLETE
PostgreSQL ETL load         ✅ COMPLETE

PostgreSQL validation       ⏳ NEXT
SQL analytical queries      ⏳ NEXT
Power BI dashboard          ⏳ NEXT
Final documentation         ⏳ FINAL
GitHub portfolio polish     ⏳ FINAL
```

---

# Engineering Lessons Learned

This project has covered several important data-engineering concepts:

* REST API data extraction
* JSON structures
* Python dictionaries and lists
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
* Idempotent development loads
* Referential integrity
* SQL analytical workflows
* Data quality gates
* Preparing relational data for BI

---

# Next Session

The immediate next task is:

```text
PostgreSQL ETL VALIDATION
        ↓
SQL ANALYSIS
        ↓
POWER BI
        ↓
FINAL DOCUMENTATION
        ↓
GITHUB PORTFOLIO
```

The Pokémon project will be completed end-to-end before moving to the next major project:

```text
software-engineering-knowledge
```

The `software-engineering-knowledge` project is intended to be a **continuous long-term project** rather than a finite project.

It will eventually incorporate a local agent to automate the capture, curation, organization, indexing, documentation, and Git/GitHub workflow for accumulated software-engineering knowledge.
