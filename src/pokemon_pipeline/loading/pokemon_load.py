# Import libraries for reading the CSV, converting list strings, and connecting to PostgreSQL.
import ast
import os
from pathlib import Path

import pandas as pd
import psycopg2

# Find the project root directory.
project_root = Path(__file__).resolve().parents[3]

# Define the cleaned data input path.
csv_file = project_root / "data" / "processed" / "pokemon_clean.csv"

# Define the PostgreSQL connection settings for the local project database.
db_config = {
    "host": "localhost",
    "port": 5432,
    "database": "pokemon_data",
    "user": "postgres",
    "password": os.environ["POSTGRES_PASSWORD"]
}
# Load the cleaned Pokémon dataset into a Pandas DataFrame.
df = pd.read_csv(csv_file)
# Convert the types column from a CSV string back into a Python list.
df["types"] = df["types"].apply(ast.literal_eval)
# Convert the abilities column from a CSV string back into a Python list.
df["abilities"] = df["abilities"].apply(ast.literal_eval)
# Display the number of Pokémon records that will be loaded.
print(f"Records to load: {len(df)}")
# Connect Python to the PostgreSQL pokemon_data database.
conn = psycopg2.connect(**db_config)
# Create a cursor for executing SQL statements.
cursor = conn.cursor()
try:
    # Remove existing data so the loading process can be safely rerun during development.
    cursor.execute("TRUNCATE TABLE pokemon RESTART IDENTITY CASCADE;")
    # Define the SQL statement used to insert Pokémon into the main table.
    pokemon_sql = """
        INSERT INTO pokemon (
            id,
            name,
            height,
            weight,
            base_experience,
            hp,
            attack,
            defense,
            special_attack,
            special_defense,
            speed,
            type_count,
            ability_count
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """
    # Insert the scalar Pokémon data into the pokemon table.
    for _, row in df.iterrows():
        cursor.execute(
            pokemon_sql,
            (
                int(row["id"]),
                row["name"],
                int(row["height"]),
                int(row["weight"]),
                None if pd.isna(row["base_experience"]) else int(row["base_experience"]),
                int(row["hp"]),
                int(row["attack"]),
                int(row["defense"]),
                int(row["special_attack"]),
                int(row["special_defense"]),
                int(row["speed"]),
                int(row["type_count"]),
                int(row["ability_count"])
            )
        )
    # Define the SQL statement used to insert Pokémon types.
    type_sql = """
        INSERT INTO pokemon_types (pokemon_id, type)
        VALUES (%s, %s)
    """
    # Insert one row for each Pokémon-type relationship.
    for _, row in df.iterrows():
        for pokemon_type in row["types"]:
            cursor.execute(
                type_sql,
                (int(row["id"]), pokemon_type)
            )
    # Define the SQL statement used to insert Pokémon abilities.
    ability_sql = """
        INSERT INTO pokemon_abilities (pokemon_id, ability)
        VALUES (%s, %s)
    """
    # Insert one row for each Pokémon-ability relationship.
    for _, row in df.iterrows():
        for ability in row["abilities"]:
            cursor.execute(
                ability_sql,
                (int(row["id"]), ability)
            )
    # Commit all database changes as one transaction.
    conn.commit()
    # Confirm that the complete load was successful.
    print("Data load completed successfully.")
except Exception as e:
    # Undo all database changes if an error occurs during the load.
    conn.rollback()
    print("Data load failed.")
    print("Error:", e)
finally:
    # Close the database cursor.
    cursor.close()
    # Close the PostgreSQL connection.
    conn.close()
    print("Database connection closed.")