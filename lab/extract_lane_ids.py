import argparse
import json
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('output', type=Path, help='Path to output text file')

args = parser.parse_args()
output_path = args.output

raw_data = input('Paste data...')
data = json.loads(raw_data)

lane_ids = [lane['id'] for lane in data['lanes']]

with open(output_path, 'w') as f:
    f.write('\n'.join(lane_ids))
