```sql
-- ============================================================
-- POKÉMON DATA ENGINEERING PROJECT
-- Data Validation and Quality Checks
-- PostgreSQL 18
-- ============================================================

-- Connect to the "pokemon_data" database before running.
-- ============================================================
-- 1. DATABASE CHECK
-- ============================================================

SELECT current_database();


-- ============================================================
-- 2. TABLE CHECK
-- ============================================================

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;


-- ============================================================
-- 3. ROW COUNT VALIDATION
-- ============================================================

SELECT 'pokemon' AS table_name, COUNT(*) AS row_count
FROM pokemon

UNION ALL

SELECT 'pokemon_types', COUNT(*)
FROM pokemon_types

UNION ALL

SELECT 'pokemon_abilities', COUNT(*)
FROM pokemon_abilities;


-- ============================================================
-- 4. NULL VALUE VALIDATION
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
-- 5. EXPECTED BASE EXPERIENCE NULLS
-- ============================================================

SELECT COUNT(*) AS base_experience_nulls
FROM pokemon
WHERE base_experience IS NULL;


-- ============================================================
-- 6. DUPLICATE ID VALIDATION
-- ============================================================

SELECT
    id,
    COUNT(*) AS duplicate_count
FROM pokemon
GROUP BY id
HAVING COUNT(*) > 1;


-- ============================================================
-- 7. DUPLICATE NAME VALIDATION
-- ============================================================

SELECT
    name,
    COUNT(*) AS duplicate_count
FROM pokemon
GROUP BY name
HAVING COUNT(*) > 1;


-- ============================================================
-- 8. FOREIGN KEY / ORPHAN VALIDATION
-- ============================================================

SELECT COUNT(*) AS orphan_type_records
FROM pokemon_types pt
LEFT JOIN pokemon p
    ON pt.pokemon_id = p.id
WHERE p.id IS NULL;


SELECT COUNT(*) AS orphan_ability_records
FROM pokemon_abilities pa
LEFT JOIN pokemon p
    ON pa.pokemon_id = p.id
WHERE p.id IS NULL;


-- ============================================================
-- 9. TYPE COUNT CONSISTENCY
-- ============================================================

SELECT
    p.id,
    p.name,
    p.type_count,
    COUNT(pt.type) AS actual_type_count
FROM pokemon p
LEFT JOIN pokemon_types pt
    ON p.id = pt.pokemon_id
GROUP BY
    p.id,
    p.name,
    p.type_count
HAVING p.type_count <> COUNT(pt.type);


-- ============================================================
-- 10. ABILITY COUNT CONSISTENCY
-- ============================================================

SELECT
    p.id,
    p.name,
    p.ability_count,
    COUNT(pa.ability) AS actual_ability_count
FROM pokemon p
LEFT JOIN pokemon_abilities pa
    ON p.id = pa.pokemon_id
GROUP BY
    p.id,
    p.name,
    p.ability_count
HAVING p.ability_count <> COUNT(pa.ability);


-- ============================================================
-- 11. STAT VALIDATION
-- ============================================================

SELECT COUNT(*) AS invalid_stat_records
FROM pokemon
WHERE hp < 0
   OR attack < 0
   OR defense < 0
   OR special_attack < 0
   OR special_defense < 0
   OR speed < 0;


-- ============================================================
-- 12. HEIGHT AND WEIGHT VALIDATION
-- ============================================================

SELECT COUNT(*) AS invalid_measurement_records
FROM pokemon
WHERE height <= 0
   OR weight < 0;


-- ============================================================
-- 13. OVERALL ETL CONSISTENCY
-- ============================================================

SELECT
    (SELECT COUNT(*) FROM pokemon) AS pokemon_count,

    (SELECT COUNT(*) FROM pokemon_types)
        AS type_relationships,

    (SELECT COUNT(*) FROM pokemon_abilities)
        AS ability_relationships,

    (SELECT COALESCE(SUM(type_count), 0) FROM pokemon)
        AS expected_type_relationships,

    (SELECT COALESCE(SUM(ability_count), 0) FROM pokemon)
        AS expected_ability_relationships;
```
