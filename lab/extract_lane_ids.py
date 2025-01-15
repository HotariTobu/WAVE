import argparse
import json
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument("output", type=Path, help="Path to output text file")
parser.add_argument(
    "-d", "--data", dest="data", type=Path, help="Path to input data json file"
)

args = parser.parse_args()
output_path: Path = args.output
data_path: Path = args.data

if data_path:
    with open(data_path, "r") as f:
        raw_data = f.read()
else:
    raw_data = input("Paste data...")

data = json.loads(raw_data)

lane_ids = [lane["id"] for lane in data["lanes"]]

with open(output_path, "w") as f:
    f.write("\n".join(lane_ids))
