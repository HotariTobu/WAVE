import argparse
import csv
import math
from collections import defaultdict
from pathlib import Path

COLS = ['x', 'y']
FILENAME = 'speed_by_space.csv'

parser = argparse.ArgumentParser()
parser.add_argument('input', type=Path, help='Path to input dir which has pos csv files')

args = parser.parse_args()
input_dir_path: Path = args.input

if not input_dir_path.is_dir():
    exit(1)

input_file_paths = input_dir_path.glob('*.csv')

sum_dict = defaultdict(lambda: (float(), int()))

for input_file_path in input_file_paths:
    with open(input_file_path, 'r') as f:
        r = csv.reader(f)
        cols = next(r)
        if cols[:len(COLS)] != COLS:
            continue

        def parse(row: list[str]):
            x, y, space_id = row
            return (float(x), float(y), space_id)

        last_x, last_y, space_id = parse(next(r))

        for row in r:
            x, y, id = parse(row)

            dis = math.hypot(last_x - x, last_y - y)

            sum_dis, count = sum_dict[space_id]
            sum_dict[space_id] = (sum_dis + dis, count + 1)

            if id:
                space_id = id

output_file_path = input_dir_path / FILENAME

with open(output_file_path, 'w') as f:
    w = csv.writer(f)
    w.writerow(['space_id', 'sum_dis', 'count'])

    for space_id, (sum_dis, count) in sum_dict.items():
        w.writerow([space_id, sum_dis, count])
