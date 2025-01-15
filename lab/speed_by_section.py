import argparse
import csv
from collections import defaultdict
from pathlib import Path

COLS = ['space_id', 'sum_dis', 'count']
FILENAME = 'speed_by_section.csv'
SPACE_DICT_DIR_PATH = Path(__file__).parent / 'space_dict'

parser = argparse.ArgumentParser()
parser.add_argument('input', type=Path, help='Path to speed_by_space.csv')

args = parser.parse_args()
input_file_path: Path = args.input

if not input_file_path.is_file():
    exit(1)

space_dict = defaultdict(list)

for space_dict_file_path in SPACE_DICT_DIR_PATH.iterdir():
    section_code = space_dict_file_path.stem
    with open(space_dict_file_path, 'r') as f:
        for line in f:
            space_id = line.strip()
            space_dict[space_id].append(section_code)

sum_dict = defaultdict(lambda: (float(), int()))

with open(input_file_path, 'r') as f:
    r = csv.reader(f)
    cols = next(r)
    if cols[:len(COLS)] != COLS:
        exit(2)

    def parse(row: list[str]):
        space_id, sum_dis, count = row
        return space_id, float(sum_dis), int(count)

    for row in r:
        if not row:
            continue

        space_id, dis, sub_count = parse(row)
        if space_id not in space_dict:
            continue

        section_codes = space_dict[space_id]

        for section_code in section_codes:
            sum_dis, count = sum_dict[section_code]
            sum_dict[section_code] = (sum_dis + dis, count + sub_count)

output_file_path = input_file_path.parent / FILENAME

with open(output_file_path, 'w', newline='') as f:
    w = csv.writer(f)
    w.writerow(['section_code', 'sum_dis', 'count'])

    for space_id, (sum_dis, count) in sum_dict.items():
        w.writerow([space_id, sum_dis, count])
