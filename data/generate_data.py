import pandas as pd
import numpy as np
from datetime import datetime, timedelta


def generate_transit_data(rows=5000):
    data = []
    start_time = datetime(2026, 3, 25, 6, 0, 0)  # 6 AM Start

    for i in range(rows):
        route_id = np.random.randint(1, 11)
        station_id = np.random.randint(1, 51)
        scheduled = start_time + timedelta(minutes=i * 2)

        # 20% chance of a 2-minute "maintenance delay"
        delay = 2 if np.random.random() < 0.20 else 0
        actual = scheduled + timedelta(minutes=delay)

        data.append([route_id, station_id, scheduled, actual])

    df = pd.DataFrame(
        data, columns=['route_id', 'station_id', 'arrival_time', 'actual_arrival_time'])
    df.to_csv('data/raw_transit_data.csv', index=False)
    print(f"Generated {rows} rows in data/raw_transit_data.csv")


if __name__ == "__main__":
    generate_transit_data(10000)  # Scale to 10k rows
