# How to connect to an API using Python
'''
import requests

base_url = "https://pokeapi.co/api/v2"

def get_pokemon_info(name):
    url = f"{base_url}/pokemon/{name}"
    response = requests.get(url, timeout=10)
    print(response.status_code)
    if response.status_code == 200:
        #print("Data was retrieved")
        pokemon_data = response.json()
        #print(type(response))
        #print(pokemon_data)
        return pokemon_data
    else:
        print(f"failed to retrieve data {response.status_code} ")

pokemon_name = input("Please enter the Pokemon name: ").strip().lower()
pokemon_info = get_pokemon_info(pokemon_name)

if pokemon_info:
    print(f"Name: {pokemon_info['name'].capitalize()}")
    print(f"ID: {pokemon_info['id']}")
    print(f"Height: {pokemon_info['height']}")
    print(f"Weight: {pokemon_info['weight']}")

'''
#🧠🧠 SMARTER METHOD
#----------------------------------------------------------------------------------------------------

import requests
import pandas as pd
import time
from pathlib import Path

base_url = "https://pokeapi.co/api/v2"

session = requests.Session()


def get_all_pokemon():

    url = f"{base_url}/pokemon?limit=2000"

    response = session.get(url, timeout=20)

    print(f"Status code: {response.status_code}")

    if response.status_code == 200:
        pokemon_data = response.json()
        return pokemon_data["results"]

    print(f"Failed to retrieve Pokemon list: {response.status_code}")
    return []


def get_pokemon_details(url):

    for attempt in range(3):

        try:
            response = session.get(url, timeout=20)

            if response.status_code == 200:

                pokemon = response.json()

                return {
                    "id": pokemon["id"],
                    "name": pokemon["name"],
                    "height": pokemon["height"],
                    "weight": pokemon["weight"],
                    "base_experience": pokemon["base_experience"],
                    "types": [t["type"]["name"] for t in pokemon["types"]],
                    "abilities": [a["ability"]["name"] for a in pokemon["abilities"]],
                    "hp": pokemon["stats"][0]["base_stat"],
                    "attack": pokemon["stats"][1]["base_stat"],
                    "defense": pokemon["stats"][2]["base_stat"],
                    "special_attack": pokemon["stats"][3]["base_stat"],
                    "special_defense": pokemon["stats"][4]["base_stat"],
                    "speed": pokemon["stats"][5]["base_stat"]
                }

            print(f"HTTP error {response.status_code}: {url}")

        except requests.exceptions.RequestException as e:

            print(f"Attempt {attempt + 1} failed: {e}")

            time.sleep(2)

    return None


# Get Pokemon list
pokemon_list = get_all_pokemon()

print(f"Number of Pokemon: {len(pokemon_list)}")


# Get details
all_pokemon = []

for i, pokemon in enumerate(pokemon_list, start=1):

    pokemon_details = get_pokemon_details(pokemon["url"])

    if pokemon_details:
        all_pokemon.append(pokemon_details)

    # Show progress every 100 Pokemon
    if i % 100 == 0:
        print(f"Processed {i}/{len(pokemon_list)}")


print(f"Total Pokemon retrieved: {len(all_pokemon)}")


# Convert to DataFrame
df = pd.DataFrame(all_pokemon)

print("\nFirst 5 Pokemon:")
print(df.head())

print("\nDataFrame shape:")
print(df.shape)

print("\nColumns:")
print(df.columns)

# Find the project root directory.
project_root = Path(__file__).resolve().parents[3]

# Define the raw data output path.
raw_data_path = project_root / "data" / "raw" / "pokemon_raw.csv"

# Save the extracted data.
df.to_csv(raw_data_path, index=False)

print("\nCSV file created successfully!")

