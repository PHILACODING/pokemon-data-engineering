-- ============================================================
-- POKÉMON DATA ENGINEERING PROJECT
-- Database Setup + Schema
-- PostgreSQL 18
-- ============================================================

-- ============================================================
-- DATABASE SETUP
-- IMPORTANT: Run this section while connected to the "postgres"
-- database, NOT while connected to "pokemon_data".
-- ============================================================

-- Terminate any existing sessions connected to the project database.
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'pokemon_data'
  AND pid <> pg_backend_pid();

-- Drop the project database so the environment can be rebuilt cleanly.
DROP DATABASE IF EXISTS pokemon_data;

-- Create a fresh project database.
CREATE DATABASE pokemon_data;

-- ============================================================
-- TABLE SETUP
-- IMPORTANT: After creating the database, connect the Query Tool
-- to "pokemon_data" before executing the section below.
-- ============================================================

-- Drop child tables before the parent table because of foreign keys.
DROP TABLE IF EXISTS pokemon_abilities;
DROP TABLE IF EXISTS pokemon_types;
DROP TABLE IF EXISTS pokemon;

-- Main Pokémon table.
CREATE TABLE pokemon (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    height INTEGER NOT NULL,
    weight INTEGER NOT NULL,
    base_experience INTEGER,
    hp INTEGER NOT NULL,
    attack INTEGER NOT NULL,
    defense INTEGER NOT NULL,
    special_attack INTEGER NOT NULL,
    special_defense INTEGER NOT NULL,
    speed INTEGER NOT NULL,
    type_count INTEGER NOT NULL,
    ability_count INTEGER NOT NULL
);

-- Normalized Pokémon types table.
CREATE TABLE pokemon_types (
    pokemon_id INTEGER NOT NULL,
    type VARCHAR(30) NOT NULL,
    PRIMARY KEY (pokemon_id, type),
    CONSTRAINT fk_pokemon_types_pokemon
        FOREIGN KEY (pokemon_id)
        REFERENCES pokemon(id)
        ON DELETE CASCADE
);

-- Normalized Pokémon abilities table.
CREATE TABLE pokemon_abilities (
    pokemon_id INTEGER NOT NULL,
    ability VARCHAR(100) NOT NULL,
    PRIMARY KEY (pokemon_id, ability),
    CONSTRAINT fk_pokemon_abilities_pokemon
        FOREIGN KEY (pokemon_id)
        REFERENCES pokemon(id)
        ON DELETE CASCADE
);

-- Index for queries filtering or grouping by type.
CREATE INDEX idx_pokemon_types_type
    ON pokemon_types(type);

-- Index for queries filtering or grouping by ability.
CREATE INDEX idx_pokemon_abilities_ability
    ON pokemon_abilities(ability);

-- Verify that our three Pokémon tables exist in the public schema.
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

SELECT *
FROM pokemon
LIMIT 5;

--========================================================
-- 07 September 2026
-- SQL stage of Pokemon Data Engineering
--=============================================================

-- show the current db
SELECT current_database();

-- ============================================================
-- STEP 2: INSPECT DATABASE TABLES
-- Purpose: Confirm that our three project tables exist
-- inside the public schema.
-- ============================================================

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- ============================================================
-- STEP 3: INSPECT ROW COUNTS
-- Purpose: Confirm how many records were loaded into each
-- Pokémon table.
--
-- pokemon            → one row per Pokémon
-- pokemon_types      → Pokémon-to-type relationships
-- pokemon_abilities  → Pokémon-to-ability relationships
-- ============================================================

SELECT 'pokemon' AS table_name, COUNT(*) AS row_count
FROM pokemon

UNION ALL

SELECT 'pokemon_types' AS table_name, COUNT(*) AS row_count
FROM pokemon_types

UNION ALL

SELECT 'pokemon_abilities' AS table_name, COUNT(*) AS row_count
FROM pokemon_abilities;

-- ============================================================
-- STEP 4: INSPECT THE MAIN POKÉMON TABLE
-- Purpose: Examine the structure of the pokemon table.
--
-- We want to see:
--   • Column names
--   • Data types
--   • Whether NULL values are allowed
--   • Default values, if any
-- ============================================================

SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'pokemon'
ORDER BY ordinal_position;

-- ============================================================
-- STEP 5: INSPECT PRIMARY KEY
-- Purpose: Confirm that pokemon.id is the primary key.
--
-- A primary key:
--   • Uniquely identifies each row
--   • Cannot contain NULL
--   • Prevents duplicate IDs
--   • Provides the parent key for our foreign keys
-- ============================================================

SELECT
    constraint_name,
    constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'public'
  AND table_name = 'pokemon'
  AND constraint_type = 'PRIMARY KEY';


-- ============================================================
-- STEP 6: INSPECT FOREIGN KEY CONSTRAINTS
-- Purpose: Confirm that pokemon_types and pokemon_abilities
-- are correctly linked to the pokemon table.
--
-- This enforces referential integrity:
-- a type or ability record cannot reference a Pokémon
-- that does not exist in the pokemon table.
-- ============================================================

SELECT
    table_name,
    constraint_name,
    constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'public'
  AND table_name IN ('pokemon_types', 'pokemon_abilities')
  AND constraint_type = 'FOREIGN KEY'
ORDER BY table_name;

-- ============================================================
-- STEP 7: INSPECT FOREIGN-KEY COLUMNS
-- Purpose: Identify the columns that connect our child tables
-- to the parent pokemon table.
--
-- Expected relationships:
--
-- pokemon_types.pokemon_id
--          ↓
--      pokemon.id
--
-- pokemon_abilities.pokemon_id
--          ↓
--      pokemon.id
-- ============================================================

SELECT
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS referenced_table,
    ccu.column_name AS referenced_column
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON tc.constraint_name = ccu.constraint_name
    AND tc.table_schema = ccu.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_schema = 'public'
ORDER BY tc.table_name;

-- ============================================================
-- STEP 8: INSPECT SAMPLE DATA
-- Purpose: View actual records in the main pokemon table.
--
-- We are checking:
--   • Whether the data looks correct
--   • Column values
--   • Data types in practice
--   • Whether our transformations produced sensible results
--
-- LIMIT 10 keeps the result small and readable.
-- ============================================================

SELECT *
FROM pokemon
ORDER BY id
LIMIT 10;

-- ============================================================
-- STEP 9: INSPECT POKÉMON TYPES
-- Purpose: View the relationships between Pokémon and their
-- assigned types.
--
-- pokemon_id → identifies the Pokémon
-- type       → stores the Pokémon's type
--
-- A Pokémon can have more than one type, which is why this
-- information is stored in a separate normalized table.
-- ============================================================

SELECT *
FROM pokemon_types
ORDER BY pokemon_id
LIMIT 15;

-- ============================================================
-- STEP 10: INSPECT POKÉMON ABILITIES
-- Purpose: View the relationships between Pokémon and their
-- assigned abilities.
--
-- pokemon_id → identifies the Pokémon
-- ability    → stores the Pokémon's ability
--
-- A Pokémon can have multiple abilities, so this information
-- is stored separately from the main pokemon table.
-- ============================================================

SELECT *
FROM pokemon_abilities
ORDER BY pokemon_id
LIMIT 15;

-- ============================================================
-- STEP 11: CHECK FOR NULL VALUES
-- Purpose: Count NULL values in every column of the main
-- pokemon table.
--
-- NULL means that a value is missing/unknown.
-- This is an important data-quality check before analysis.
-- ============================================================

SELECT
    COUNT(*) FILTER (WHERE id IS NULL) AS id_nulls,
    COUNT(*) FILTER (WHERE name IS NULL) AS name_nulls,
    COUNT(*) FILTER (WHERE height IS NULL) AS height_nulls,
    COUNT(*) FILTER (WHERE weight IS NULL) AS weight_nulls,
    COUNT(*) FILTER (WHERE base_experience IS NULL) AS base_experience_nulls,
    COUNT(*) FILTER (WHERE hp IS NULL) AS hp_nulls,
    COUNT(*) FILTER (WHERE attack IS NULL) AS attack_nulls,
    COUNT(*) FILTER (WHERE defense IS NULL) AS defense_nulls,
    COUNT(*) FILTER (WHERE special_attack IS NULL) AS special_attack_nulls,
    COUNT(*) FILTER (WHERE special_defense IS NULL) AS special_defense_nulls,
    COUNT(*) FILTER (WHERE speed IS NULL) AS speed_nulls,
    COUNT(*) FILTER (WHERE type_count IS NULL) AS type_count_nulls,
    COUNT(*) FILTER (WHERE ability_count IS NULL) AS ability_count_nulls
FROM pokemon;

-- ============================================================
-- STEP 12: INVESTIGATE NULL BASE EXPERIENCE
-- Purpose: Identify the Pokémon records where base_experience
-- is missing.
--
-- We are investigating before deciding whether the NULLs
-- represent a problem.
-- ============================================================

SELECT
    id,
    name,
    base_experience
FROM pokemon
WHERE base_experience IS NULL
ORDER BY id;








