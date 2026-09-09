-- ============================================================
-- POKÉMON DATA ENGINEERING PROJECT
-- Database Setup
-- PostgreSQL 18
-- ============================================================

-- IMPORTANT:
-- Run this section while connected to the "postgres" database,
-- NOT while connected to "pokemon_data".

-- Terminate any existing sessions connected to the project database.
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'pokemon_data'
  AND pid <> pg_backend_pid();

-- Drop the project database so the environment can be rebuilt cleanly.
DROP DATABASE IF EXISTS pokemon_data;

-- Create a fresh project database.
CREATE DATABASE pokemon_data;
