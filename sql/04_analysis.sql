-- ============================================================
-- POKÉMON DATA ENGINEERING PROJECT
-- Analytical SQL
-- PostgreSQL 18
-- ============================================================

-- Analysis 1: Pokémon Type Distribution
-- Shows how many Pokémon are associated with each type.

SELECT
    type,
    COUNT(*) AS pokemon_count
FROM pokemon_types
GROUP BY type
ORDER BY pokemon_count DESC;

-- ============================================================
-- Analysis 2: Top Pokémon by Total Base Stats
-- ============================================================

SELECT
    id,
    name,
    hp,
    attack,
    defense,
    special_attack,
    special_defense,
    speed,

    (
        hp
        + attack
        + defense
        + special_attack
        + special_defense
        + speed
    ) AS total_stats

FROM pokemon

ORDER BY total_stats DESC
LIMIT 20;


-- ============================================================
-- Analysis 3: Most Common Pokémon Abilities
-- ============================================================

SELECT
    ability,
    COUNT(*) AS pokemon_count
FROM pokemon_abilities
GROUP BY ability
ORDER BY pokemon_count DESC
LIMIT 20;


-- ============================================================
-- Analysis 4: Average Combat Stats by Pokémon Type
-- ============================================================

SELECT
    pt.type,

    COUNT(DISTINCT p.id) AS pokemon_count,

    ROUND(AVG(p.hp), 2) AS avg_hp,
    ROUND(AVG(p.attack), 2) AS avg_attack,
    ROUND(AVG(p.defense), 2) AS avg_defense,
    ROUND(AVG(p.special_attack), 2) AS avg_special_attack,
    ROUND(AVG(p.special_defense), 2) AS avg_special_defense,
    ROUND(AVG(p.speed), 2) AS avg_speed

FROM pokemon p

JOIN pokemon_types pt
    ON p.id = pt.pokemon_id

GROUP BY pt.type

ORDER BY avg_attack DESC;

-- ============================================================
-- Analysis 5: Single-Type vs Dual-Type Pokémon
-- ============================================================

SELECT
    CASE
        WHEN type_count = 1 THEN 'Single Type'
        WHEN type_count = 2 THEN 'Dual Type'
        ELSE 'Other'
    END AS type_category,

    COUNT(*) AS pokemon_count

FROM pokemon

GROUP BY
    CASE
        WHEN type_count = 1 THEN 'Single Type'
        WHEN type_count = 2 THEN 'Dual Type'
        ELSE 'Other'
    END

ORDER BY pokemon_count DESC;

-- ============================================================
-- Analysis 6: Highest Individual Combat Stats
-- ============================================================

SELECT
    'HP' AS stat,
    name,
    hp AS stat_value
FROM pokemon
WHERE hp = (SELECT MAX(hp) FROM pokemon)

UNION ALL

SELECT
    'Attack',
    name,
    attack
FROM pokemon
WHERE attack = (SELECT MAX(attack) FROM pokemon)

UNION ALL

SELECT
    'Defense',
    name,
    defense
FROM pokemon
WHERE defense = (SELECT MAX(defense) FROM pokemon)

UNION ALL

SELECT
    'Special Attack',
    name,
    special_attack
FROM pokemon
WHERE special_attack = (SELECT MAX(special_attack) FROM pokemon)

UNION ALL

SELECT
    'Special Defense',
    name,
    special_defense
FROM pokemon
WHERE special_defense = (SELECT MAX(special_defense) FROM pokemon)

UNION ALL

SELECT
    'Speed',
    name,
    speed
FROM pokemon
WHERE speed = (SELECT MAX(speed) FROM pokemon)

ORDER BY stat;


-- ============================================================
-- Analysis 7: Highest Base Experience
-- ============================================================

SELECT
    id,
    name,
    base_experience
FROM pokemon
WHERE base_experience IS NOT NULL
ORDER BY base_experience DESC
LIMIT 20;


-- ============================================================
-- Analysis 8: Attack + Defense Ranking
-- ============================================================

SELECT
    id,
    name,
    attack,
    defense,
    (attack + defense) AS attack_defense_total
FROM pokemon
ORDER BY attack_defense_total DESC
LIMIT 20;


-- ============================================================
-- Analysis 9: Average Total Stats by Pokémon Type
-- ============================================================

SELECT
    pt.type,
    COUNT(DISTINCT p.id) AS pokemon_count,

    ROUND(
        AVG(
            p.hp
            + p.attack
            + p.defense
            + p.special_attack
            + p.special_defense
            + p.speed
        ),
        2
    ) AS avg_total_stats

FROM pokemon p

JOIN pokemon_types pt
    ON p.id = pt.pokemon_id

GROUP BY pt.type

ORDER BY avg_total_stats DESC;

-- ============================================================
-- Analysis 10: Strongest Pokémon Within Each Type
-- ============================================================

WITH ranked_pokemon AS (
    SELECT
        pt.type,
        p.name,

        (
            p.hp
            + p.attack
            + p.defense
            + p.special_attack
            + p.special_defense
            + p.speed
        ) AS total_stats,

        ROW_NUMBER() OVER (
            PARTITION BY pt.type
            ORDER BY
                (
                    p.hp
                    + p.attack
                    + p.defense
                    + p.special_attack
                    + p.special_defense
                    + p.speed
                ) DESC
        ) AS type_rank

    FROM pokemon p

    JOIN pokemon_types pt
        ON p.id = pt.pokemon_id
)

SELECT
    type,
    name,
    total_stats
FROM ranked_pokemon
WHERE type_rank = 1
ORDER BY type;

-- ============================================================
-- Analysis 11: Fastest Pokémon
-- ============================================================

SELECT
    id,
    name,
    speed,
    attack,
    defense
FROM pokemon
ORDER BY speed DESC
LIMIT 20;

-- ============================================================
-- Analysis 12: Top 3 Pokémon Within Each Type
-- ============================================================

WITH ranked_pokemon AS (
    SELECT
        pt.type,
        p.name,

        (
            p.hp
            + p.attack
            + p.defense
            + p.special_attack
            + p.special_defense
            + p.speed
        ) AS total_stats,

        ROW_NUMBER() OVER (
            PARTITION BY pt.type
            ORDER BY
                (
                    p.hp
                    + p.attack
                    + p.defense
                    + p.special_attack
                    + p.special_defense
                    + p.speed
                ) DESC
        ) AS type_rank

    FROM pokemon p

    JOIN pokemon_types pt
        ON p.id = pt.pokemon_id
)

SELECT
    type,
    name,
    total_stats,
    type_rank
FROM ranked_pokemon
WHERE type_rank <= 3
ORDER BY
    type,
    type_rank;

-- ============================================================
-- Analysis 13: Average Total Stats by Type Category
-- ============================================================

SELECT
    CASE
        WHEN type_count = 1 THEN 'Single Type'
        WHEN type_count = 2 THEN 'Dual Type'
        ELSE 'Other'
    END AS type_category,

    COUNT(*) AS pokemon_count,

    ROUND(
        AVG(
            hp
            + attack
            + defense
            + special_attack
            + special_defense
            + speed
        ),
        2
    ) AS avg_total_stats

FROM pokemon

GROUP BY
    CASE
        WHEN type_count = 1 THEN 'Single Type'
        WHEN type_count = 2 THEN 'Dual Type'
        ELSE 'Other'
    END

ORDER BY avg_total_stats DESC;

-- ============================================================
-- Analysis 14: Most Common Dual-Type Combinations
-- ============================================================

SELECT
    t1.type AS type_1,
    t2.type AS type_2,
    COUNT(*) AS pokemon_count

FROM pokemon_types t1

JOIN pokemon_types t2
    ON t1.pokemon_id = t2.pokemon_id
    AND t1.type < t2.type

GROUP BY
    t1.type,
    t2.type

ORDER BY pokemon_count DESC;


-- ============================================================
-- Analysis 15: Abilities by Average Total Stats
-- ============================================================

SELECT
    pa.ability,
    COUNT(DISTINCT p.id) AS pokemon_count,

    ROUND(
        AVG(
            p.hp
            + p.attack
            + p.defense
            + p.special_attack
            + p.special_defense
            + p.speed
        ),
        2
    ) AS avg_total_stats

FROM pokemon p

JOIN pokemon_abilities pa
    ON p.id = pa.pokemon_id

GROUP BY pa.ability

HAVING COUNT(DISTINCT p.id) >= 10

ORDER BY avg_total_stats DESC;