import argparse
import csv
from collections import defaultdict
from pathlib import Path

import common

TRI_FILENAME_PATTERN = 'tri_*.csv'
OUTPUT_FILENAME = 'ave_speed_by_section.csv'

parser = argparse.ArgumentParser()
parser.add_argument("space_attrs", type=Path, help="Path to input space attrs.csv")
parser.add_argument('tri_dir', type=Path, help='Path to input dir which has trip time csv files')
parser.add_argument('--step-delta', dest='step_delta', type=float, default=1)

args = parser.parse_args()
space_attrs_path: Path = args.space_attrs
tri_dir_path: Path = args.tri_dir
step_delta = args.step_delta

if not tri_dir_path.is_dir():
    exit(1)

space_dict = common.get_space_dict()

space_length_dict = common.get_space_length_dict(space_attrs_path)
if space_length_dict is None:
    exit(3)

tri_file_paths = tri_dir_path.glob(TRI_FILENAME_PATTERN)

sum_dict = defaultdict(lambda: (float(), int()))

for tri_file_path in tri_file_paths:
    trail_space_id_set: set[str] = set()
    step_count_dict: dict[str, int] = {}

    with open(tri_file_path, 'r') as f:
        r = csv.reader(f)
        if not common.has_cols(r, common.TRI_COLS):
            continue

        for row in r:
            space_id, step_count = row
            trail_space_id_set.add(space_id)
            step_count_dict[space_id] = int(step_count)

    for section_code, section_space_id_set in space_dict.items():
        space_id_set = trail_space_id_set & section_space_id_set
        if not space_id_set:
            continue

        length = 0
        step_count = 0

        for space_id in space_id_set:
            length += space_length_dict[space_id]
            step_count += step_count_dict[space_id]

        seconds = step_count * step_delta
        speed = length / seconds

        sum_speed, count = sum_dict[section_code]
        sum_dict[section_code] = (sum_speed + speed, count + 1)

sum_list = list(sum_dict.items())
sum_list.sort()

for space_id, (sum_speed, count) in sum_list:
    print(space_id, sum_speed / count)
