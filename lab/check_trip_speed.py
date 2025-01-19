import argparse
import csv
from pathlib import Path

import common

TRIP_SPEED_DATA_COLS = ["section_id", "trip_speed"]
SPEED_FACTOR = 3600 / 1000

parser = argparse.ArgumentParser()
parser.add_argument(
    "--trip-speed-data",
    type=Path,
    default="trip_speed.csv",
    help="Path to csv file which has trip speed by section data",
    dest="trip_speed_data",
)

args = parser.parse_args()
trip_speed_file_path: Path = args.trip_speed_data

if not trip_speed_file_path.is_file():
    exit(1)

trip_speed_dict: dict[str, float] = {}

with open(trip_speed_file_path, "r") as f:
    r = csv.reader(f)
    if not common.has_cols(r, TRIP_SPEED_DATA_COLS):
        exit(2)

    for row in r:
        section_id, trip_speed = row
        trip_speed_dict[section_id] = float(trip_speed)

for _ in trip_speed_dict:
    line = input()
    tokens = line.split()

    section_id = tokens[0]
    simulated_trip_speed = float(tokens[1])

    trip_speed = trip_speed_dict[section_id]
    dif = abs(simulated_trip_speed * SPEED_FACTOR - trip_speed)

    result = "◎" if dif < 1 else "◯" if dif < 2 else "×"
    print(section_id, simulated_trip_speed, result, sep="\t")
