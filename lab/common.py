import csv
from pathlib import Path

SPACE_ATTRS_COLS = ["id", "length"]
POS_COLS = ["x", "y"]
TRI_COLS = ["space_id", "step_count"]

SPACE_DICT_DIR_PATH = Path(__file__).parent / "space_dict"
SPACE_DICT_FILENAME_PATTERN = "*.txt"


def has_cols(r, cols: list[str]):
    row = next(r)
    return row[: len(cols)] == cols


def get_space_dict():
    space_dict: dict[str, set[str]] = {}

    for space_dict_file_path in SPACE_DICT_DIR_PATH.glob(SPACE_DICT_FILENAME_PATTERN):
        section_code = space_dict_file_path.stem
        with open(space_dict_file_path, "r") as f:
            space_ids = [line.strip() for line in f]
            space_dict[section_code] = set(space_ids)

    return space_dict


def get_space_length_dict(space_attrs_path: Path):
    space_length_dict: dict[str, float] = {}

    with open(space_attrs_path, "r") as f:
        r = csv.reader(f)
        if not has_cols(r, SPACE_ATTRS_COLS):
            return None

        for row in r:
            space_id, length = row
            space_length_dict[space_id] = float(length)

    return space_length_dict
