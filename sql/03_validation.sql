-- ============================================================
-- POKÉMON DATA ENGINEERING PROJECT
-- Data Validation and Quality Checks
-- PostgreSQL 18
-- ============================================================

-- IMPORTANT:
-- Connect to the "pokemon_data" database before running
-- this script.

-- ============================================================
-- 1. CHECK CURRENT DATABASE
-- ============================================================

SELECT current_database();

-- ============================================================
-- 2. CHECK PROJECT TABLES
-- ============================================================

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- ============================================================
-- 3. CHECK ROW COUNTS
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
-- 4. INSPECT POKÉMON TABLE STRUCTURE
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
-- 5. CHECK PRIMARY KEY
-- ============================================================

SELECT
    constraint_name,
    constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'public'
  AND table_name = 'pokemon'
  AND constraint_type = 'PRIMARY KEY';

-- ============================================================
-- 6. CHECK FOREIGN KEY CONSTRAINTS
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
-- 7. CHECK FOREIGN KEY RELATIONSHIPS
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
-- 8. SAMPLE POKÉMON DATA
-- ============================================================

SELECT *
FROM pokemon
ORDER BY id
LIMIT 10;

-- ============================================================
-- 9. SAMPLE POKÉMON TYPES
-- ============================================================

SELECT *
FROM pokemon_types
ORDER BY pokemon_id
LIMIT 15;

-- ============================================================
-- 10. SAMPLE POKÉMON ABILITIES
-- ============================================================

SELECT *
FROM pokemon_abilities
ORDER BY pokemon_id
LIMIT 15;

-- ============================================================
-- 11. CHECK NULL VALUES
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
-- 12. INVESTIGATE NULL BASE EXPERIENCE
-- ============================================================

SELECT
    id,
    name,
    base_experience
FROM pokemon
WHERE base_experience IS NULL
ORDER BY id;
