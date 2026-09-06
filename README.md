# Pokémon Data Engineering & Analytics Pipeline

An end-to-end data engineering and analytics project built using the free PokéAPI.

The project demonstrates how data can move through a complete pipeline:

**Extract → Transform → Store → Analyze → Visualize**

The pipeline starts with Pokémon data retrieved from a REST API, processes the data using Python, Pandas and NumPy, loads the transformed data into a normalized PostgreSQL database, performs SQL analysis, and will ultimately produce an interactive Power BI dashboard.

---

## 🚀 Project Overview

The project uses PokéAPI as the external data source.

### Current architecture

```text
                    ┌─────────────────┐
                    │    PokéAPI      │
                    │    REST API     │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │     Python      │
                    │ API Extraction  │
                    │    requests     │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │   Raw CSV File  │
                    │ pokemon_raw.csv │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │ Jupyter Notebook│
                    │ Pandas / NumPy  │
                    │ Profiling / EDA │
                    │ Transformation │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │ Clean CSV File  │
                    │pokemon_clean.csv│
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │   PostgreSQL    │
                    │  Data Modeling  │
                    │   ETL Loading   │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │   SQL Analysis  │
                    │    🚧 Next      │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │    Power BI     │
                    │    ⏳ Planned   │
                    └─────────────────┘
```

---

# 🎯 Project Objectives

The main objective is to build a complete data pipeline using real API data and demonstrate practical data engineering and analytics skills.

The project covers:

* REST API data extraction
* HTTP requests
* JSON processing
* Python programming
* Pandas
* NumPy
* Data profiling
* Data quality validation
* Data cleaning
* Feature engineering
* CSV data storage
* PostgreSQL
* Relational data modeling
* SQL
* Database constraints
* Database indexes
* ETL development
* Data analysis
* Power BI
* Business intelligence
* End-to-end pipeline design

---

# 📌 Project Status

| Pipeline Stage                 | Status     |
| ------------------------------ | ---------- |
| API source                     | ✅ Complete |
| API connection                 | ✅ Complete |
| API data extraction            | ✅ Complete |
| JSON processing                | ✅ Complete |
| Raw CSV creation               | ✅ Complete |
| Pandas data profiling          | ✅ Complete |
| Data quality validation        | ✅ Complete |
| Data cleaning / transformation | ✅ Complete |
| Feature engineering            | ✅ Complete |
| Clean CSV creation             | ✅ Complete |
| PostgreSQL database            | ✅ Complete |
| PostgreSQL schema              | ✅ Complete |
| Relational tables              | ✅ Complete |
| PostgreSQL indexes             | ✅ Complete |
| Python → PostgreSQL ETL        | ✅ Complete |
| SQL analysis                   | 🚧 Next    |
| Power BI dashboard             | ⏳ Planned  |
| Final documentation            | ⏳ Planned  |

---

# 1. 🔌 Data Source — PokéAPI

The project uses PokéAPI as the external REST API data source.

The API provides structured JSON data containing Pokémon information such as:

* Pokémon ID
* Name
* Height
* Weight
* Base experience
* Types
* Abilities
* HP
* Attack
* Defense
* Special Attack
* Special Defense
* Speed

The extraction process retrieves the Pokémon collection and then requests detailed information for each Pokémon.

---

# 2. 🐍 API Data Extraction

The API extraction stage was implemented in:

```text
api_json.py
```

Python's `requests` library is used to send HTTP GET requests and process the JSON responses.

The extraction retrieved:

```text
1,351 Pokémon records
13 initial attributes
```

The resulting records were converted into Python dictionaries before being assembled into a Pandas DataFrame.

Example record:

```python
{
    "id": 1,
    "name": "bulbasaur",
    "height": 7,
    "weight": 69,
    "base_experience": 64,
    "types": ["grass", "poison"],
    "abilities": ["overgrow", "chlorophyll"],
    "hp": 45,
    "attack": 49,
    "defense": 49,
    "special_attack": 65,
    "special_defense": 65,
    "speed": 45
}
```

---

# 3. 📊 Pandas Data Transformation

The extracted data was loaded into Pandas for profiling, transformation and analysis.

Initial dataset:

```text
Rows:    1,351
Columns: 13
```

Feature engineering added:

```text
type_count
ability_count
```

Final transformed dataset:

```text
Rows:    1,351
Columns: 15
```

The final columns are:

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
type_count
ability_count
```

---

# 4. 🧪 Data Quality Analysis

The dataset was profiled and validated using Pandas and NumPy.

## Missing Values

The only column containing missing values is:

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

The source API was checked to confirm that these missing values originate from the source data.

Decision:

```text
Preserve the missing values.
```

They remain as `NaN` in Pandas and become `NULL` when loaded into PostgreSQL.

---

## Duplicate Analysis

The dataset was checked for duplicate records.

Results:

```text
Duplicate rows:       0
Duplicate IDs:       0
Duplicate names:     0
```

All 1,351 records have unique Pokémon IDs and names.

---

## Numeric Validation

The main numerical attributes were validated for invalid values.

Findings included:

* No zero or negative Pokémon heights
* No negative Pokémon weights
* One Pokémon has a weight of `0`
* The zero-weight record belongs to `eternatus-eternamax`
* Extreme values were investigated and confirmed as legitimate Pokémon/form records

The source-provided values were preserved rather than artificially modifying legitimate records.

PokéAPI measurement units:

```text
height → decimetres
weight → hectograms
```

---

# 5. 🔄 Nested Data Transformation

The API contains multiple values in the following fields:

```text
types
abilities
```

When stored in CSV format, Python lists become strings such as:

```text
"['grass', 'poison']"
```

The project uses:

```python
ast.literal_eval()
```

to safely convert these strings back into Python lists.

This makes it possible to normalize the data into relational PostgreSQL tables.

---

# 6. 📈 Pokémon Type Analysis

The dataset contains:

```text
2,116 total type assignments
```

Classification:

```text
Single-type Pokémon: 586
Dual-type Pokémon:   765
```

The most common Pokémon types include:

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

The analysis used Pandas:

```python
df["types"].explode().value_counts()
```

This demonstrates how nested list data can be flattened for analytical purposes.

---

# 7. ⚡ Pokémon Ability Analysis

The dataset contains:

```text
313 distinct abilities
```

Total ability assignments:

```text
2,941
```

Examples of common abilities include:

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

The 11 records containing empty ability lists were investigated against the source API and confirmed as legitimate source records.

Decision:

```text
Preserve empty ability lists.
```

In PostgreSQL, these Pokémon simply have no corresponding records in the `pokemon_abilities` table.

---

# 8. 💾 Clean Dataset

The transformed dataset was saved as:

```text
pokemon_clean.csv
```

The raw extracted dataset is preserved separately as:

```text
pokemon_raw.csv
```

This creates a simple data-layer separation:

```text
API
 ↓
pokemon_raw.csv
 ↓
Python / Pandas / NumPy
 ↓
pokemon_clean.csv
```

---

# 9. 🐘 PostgreSQL Database

The PostgreSQL database has been created successfully.

Database:

```text
pokemon_data
```

Schema:

```text
public
```

Database verification was performed using:

```sql
SELECT current_database(), current_schema();
```

Result:

```text
pokemon_data | public
```

PostgreSQL version used during development:

```text
PostgreSQL 18.4
```

---

# 10. 🧱 PostgreSQL Data Model

The cleaned data was normalized into three relational tables.

## Main Pokémon Table

```text
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

---

## Pokémon Types

```text
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

---

## Pokémon Abilities

```text
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

The relational design separates the multi-valued `types` and `abilities` attributes from the main Pokémon entity.

---

# 11. ⚡ PostgreSQL Indexes

Indexes were created for commonly queried attributes.

### Pokémon Types

```text
idx_pokemon_types_type
```

Index:

```text
pokemon_types(type)
```

### Pokémon Abilities

```text
idx_pokemon_abilities_ability
```

Index:

```text
pokemon_abilities(ability)
```

These indexes support filtering and aggregation queries involving Pokémon types and abilities.

---

# 12. 🔄 Python → PostgreSQL ETL

The PostgreSQL loading process was implemented in:

```text
pokemon_load.py
```

The loader uses:

```text
Python
Pandas
psycopg2
PostgreSQL
```

The ETL process:

```text
pokemon_clean.csv
       ↓
Pandas DataFrame
       ↓
Convert types / abilities
       ↓
PostgreSQL connection
       ↓
pokemon
       ↓
pokemon_types
       ↓
pokemon_abilities
```

The loader successfully processed:

```text
1,351 Pokémon records
```

The load completed successfully and the database connection was closed cleanly.

The loading process also uses a transaction with rollback handling so that database changes can be reverted if an error occurs.

---

# 13. 🧮 SQL Analysis — NEXT

The next development stage is analytical SQL.

Planned analysis includes questions such as:

* Which Pokémon have the highest total statistics?
* Which Pokémon have the highest attack?
* Which Pokémon have the highest defense?
* Which Pokémon have the highest speed?
* Which Pokémon are the heaviest?
* Which Pokémon are the tallest?
* Which Pokémon types are most common?
* What is the average statistic by Pokémon type?
* Which Pokémon have the highest combined battle statistics?
* How do Pokémon statistics differ between types?

The SQL analysis will demonstrate:

```text
SELECT
WHERE
GROUP BY
ORDER BY
JOIN
COUNT
AVG
SUM
MAX
MIN
CTE
Window Functions
```

---

# 14. 📊 Power BI — Planned

After completing the SQL analysis, the PostgreSQL data will be connected to Power BI.

The planned dashboard will explore:

* Total Pokémon
* Pokémon by type
* Ability distribution
* Average statistics
* Attack rankings
* Defense rankings
* Speed rankings
* Height and weight
* Statistical distributions
* Type comparisons
* Pokémon ranking tables

The objective is to transform the processed data into an interactive analytical product.

---

# 📁 Current Project Structure

```text
pokemon-data-engineering/
│
├── README.md
├── .gitignore
│
├── api_json.py
├── pokemon_load.py
│
├── pokemon_raw.csv
├── pokemon_clean.csv
│
├── pokemon_analysis.ipynb
│
└── project_so_far.md
```

---

# 🛠️ Technologies Used

## Data Engineering

* Python
* REST APIs
* JSON
* HTTP
* Requests

## Data Processing

* Pandas
* NumPy
* Python `ast`

## Data Analysis

* Jupyter Notebook
* Pandas
* NumPy
* SQL

## Database

* PostgreSQL
* psycopg2

## Business Intelligence

* Microsoft Power BI

## Development

* Visual Studio Code
* Git
* GitHub

---

# 🔄 End-to-End Pipeline

```text
                 EXTRACT
                    │
                    ▼
                 PokéAPI
                    │
                    ▼
            Python / Requests
                    │
                    ▼
              JSON Response
                    │
                    ▼
          Python Dictionaries
                    │
                    ▼
             Pandas DataFrame
                    │
                    ▼
              pokemon_raw.csv
                    │
                    ▼
                TRANSFORM
                    │
                    ▼
          Pandas + NumPy + EDA
                    │
                    ▼
           Data Quality Checks
                    │
                    ▼
        Cleaning + Feature Engineering
                    │
                    ▼
             pokemon_clean.csv
                    │
                    ▼
                  STORE
                    │
                    ▼
              PostgreSQL
                    │
             ┌──────┴──────┐
             ▼             ▼
          pokemon     pokemon_types
                           │
                           ▼
                    pokemon_abilities
                    │
                    ▼
                 ANALYZE
                    │
                    ▼
                SQL Analysis
                    │
                    ▼
               VISUALIZE
                    │
                    ▼
                 Power BI
                    │
                    ▼
             Analytics Dashboard
```

---

# 🧠 Key Learning Goals

This project demonstrates practical understanding of the complete data lifecycle:

**Extract → Transform → Store → Analyze → Visualize**

Rather than starting with a pre-existing CSV dataset, the project begins with an external API and builds the dataset through an automated extraction process.

Key learning areas include:

* Working with external APIs
* JSON structures
* HTTP requests
* Python automation
* Data extraction
* Data quality
* Data transformation
* Feature engineering
* Relational database design
* PostgreSQL
* SQL
* Database indexing
* ETL pipelines
* Data analysis
* Business intelligence
* End-to-end data pipeline design

---

# 🚧 Future Engineering Improvements

Future versions of the pipeline may include:

* API pagination
* HTTP request sessions
* Retry mechanisms
* Rate-limit handling
* Incremental extraction
* Structured logging
* Configuration files
* Environment variables
* Automated data validation
* ETL orchestration
* Docker
* Automated pipeline scheduling
* Cloud storage
* Cloud data warehouse integration

---

# 📌 Current Milestone

## Milestone 3 — PostgreSQL ETL

**Status: 🟢 Completed**

The project has successfully progressed through:

```text
PokéAPI
   ↓
Python API Extraction
   ↓
Raw CSV
   ↓
Pandas / NumPy
   ↓
Data Profiling
   ↓
Data Cleaning & Transformation
   ↓
Clean CSV
   ↓
PostgreSQL Database
   ↓
Normalized Tables
   ↓
Python ETL Load
```

### Next milestone

> **SQL Analysis → Power BI Dashboard**

The project is being developed incrementally, with each pipeline stage implemented, tested and documented before moving to the next stage.
