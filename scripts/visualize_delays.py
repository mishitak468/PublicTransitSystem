import os
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from sqlalchemy import create_engine

# Create the docs directory if it doesn't exist
if not os.path.exists('docs'):
    os.makedirs('docs')
    print("Created 'docs/' directory for project assets.")

# Setup Connection using SQLAlchemy (Fixes the UserWarning)
db_pass = os.getenv("DB_PASS")
# Format: mysql+mysqlconnector://user:password@host/database
engine = create_engine(
    f"mysql+mysqlconnector://root:{db_pass}@localhost/TransitSystem")

# Updated Query using the correct table name 'Schedule'
query = """
SELECT 
    station_id, 
    HOUR(arrival_time) as hr, 
    AVG(TIMESTAMPDIFF(MINUTE, arrival_time, arrival_time)) as delay 
FROM Schedule 
GROUP BY station_id, hr
"""

try:
    df = pd.read_sql(query, engine)

    if df.empty:
        print("No data found in the Schedule table. Run the C engine first!")
    else:
        pivot_df = df.pivot(index='station_id', columns='hr', values='delay')
        plt.figure(figsize=(12, 8))
        sns.heatmap(pivot_df, cmap='YlOrRd', annot=True)
        plt.title('Transit Congestion Heatmap: Delay Severity by Hour')
        plt.savefig('docs/delay_heatmap.png')
        print("Success! Heatmap saved to docs/delay_heatmap.png")
        plt.show()

except Exception as e:
    print(f"Error: {e}")
