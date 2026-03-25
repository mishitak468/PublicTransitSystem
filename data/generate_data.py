import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import os


def generate_enterprise_dataset(rows=100000):
    os.makedirs('data', exist_ok=True)
    data = []
    base_time = datetime(2026, 3, 25, 0, 0, 0)

    print(f"Generating {rows} rows with intentional data corruption...")
    for i in range(rows):
        # 2% chance of "corrupt" data (Station ID = -1 or NULL)
        is_corrupt = np.random.random() < 0.02

        route_id = np.random.randint(100, 999)
        station_id = -1 if is_corrupt else np.random.randint(1, 100)

        scheduled = base_time + timedelta(seconds=i * 10)

        # Stochastic delay logic
        delay = np.random.randint(0, 5) if np.random.random(
        ) < 0.90 else np.random.randint(10, 60)
        actual = scheduled + timedelta(minutes=delay)

        data.append([route_id, station_id, scheduled, actual])

    df = pd.DataFrame(
        data, columns=['route_id', 'station_id', 'scheduled', 'actual'])
    df.to_csv('data/raw_transit_data.csv', index=False)
    print("100,000 row dataset created with 2% intentional errors.")


if __name__ == "__main__":
    generate_enterprise_dataset()
