```sh
python trip_time_by_space.py '$STATS_DIR/lane/attrs.csv' '$STATS_DIR/vehicle'
python ave_speed_by_section.py '$STATS_DIR/lane/attrs.csv' '$STATS_DIR/vehicle'
 | python check_trip_speed.py
```
