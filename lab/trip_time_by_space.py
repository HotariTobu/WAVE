import argparse
import csv
from pathlib import Path

import common

POS_FILENAME_PATTERN = "pos_*.csv"
TRI_FILENAME_TEMPLATE = "tri_{}.csv"

parser = argparse.ArgumentParser()
parser.add_argument("space_attrs", type=Path, help="Path to input space attrs.csv")
parser.add_argument(
    "pos_dir", type=Path, help="Path to input dir which has pos csv files"
)

args = parser.parse_args()
space_attrs_path: Path = args.space_attrs
pos_dir_path: Path = args.pos_dir

if not space_attrs_path.is_file():
    exit(1)

if not pos_dir_path.is_dir():
    exit(2)

space_length_dict = common.get_space_length_dict(space_attrs_path)
if space_length_dict is None:
    exit(3)

pos_file_paths = pos_dir_path.glob(POS_FILENAME_PATTERN)

for i, pos_file_path in enumerate(pos_file_paths):
    tri_file_path = pos_dir_path / TRI_FILENAME_TEMPLATE.format(i)

    with open(pos_file_path, "r") as fi, open(tri_file_path, "w", newline="") as fo:
        r = csv.reader(fi)
        if not common.has_cols(r, common.POS_COLS):
            continue

        w = csv.writer(fo)
        w.writerow(common.TRI_COLS)

        space_id = ""
        step_count = 0

        def write():
            if space_id:
                w.writerow([space_id, step_count])

        for row in r:
            if not row:
                continue

            _, _, id = row
            if id:
                write()

                space_id = id
                step_count = 0

            step_count += 1

        write()
