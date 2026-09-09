-- ============================================================
-- POKÉMON DATA ENGINEERING PROJECT
-- Database Schema
-- PostgreSQL 18
-- ============================================================

-- IMPORTANT:
-- Connect to the "pokemon_data" database before running
-- this script.

-- ============================================================
-- DROP EXISTING TABLES
-- ============================================================

-- Drop child tables before the parent table because of
-- foreign-key relationships.
DROP TABLE IF EXISTS pokemon_abilities;
DROP TABLE IF EXISTS pokemon_types;
DROP TABLE IF EXISTS pokemon;

-- ============================================================
-- MAIN POKÉMON TABLE
-- ============================================================

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

-- ============================================================
-- POKÉMON TYPES
-- ============================================================

CREATE TABLE pokemon_types (
    pokemon_id INTEGER NOT NULL,
    type VARCHAR(30) NOT NULL,
    PRIMARY KEY (pokemon_id, type),
    CONSTRAINT fk_pokemon_types_pokemon
        FOREIGN KEY (pokemon_id)
        REFERENCES pokemon(id)
        ON DELETE CASCADE
);

-- ============================================================
-- POKÉMON ABILITIES
-- ============================================================

CREATE TABLE pokemon_abilities (
    pokemon_id INTEGER NOT NULL,
    ability VARCHAR(100) NOT NULL,
    PRIMARY KEY (pokemon_id, ability),
    CONSTRAINT fk_pokemon_abilities_pokemon
        FOREIGN KEY (pokemon_id)
        REFERENCES pokemon(id)
        ON DELETE CASCADE
);

-- ============================================================
-- INDEXES
-- ============================================================

-- Speeds up queries filtering or grouping by Pokémon type.
CREATE INDEX idx_pokemon_types_type
    ON pokemon_types(type);

-- Speeds up queries filtering or grouping by Pokémon ability.
CREATE INDEX idx_pokemon_abilities_ability
    ON pokemon_abilities(ability);
