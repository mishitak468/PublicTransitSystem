import psycopg2
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt


def generate_heatmap():
    # Connect to PostgreSQL
    conn = psycopg2.connect(dbname="TransitSystem",
                            user="postgres", host="localhost")

    # Query the 98,000+ clean records
    query = "SELECT route_id, station_id, EXTRACT(EPOCH FROM (actual - scheduled))/60 as delay_min FROM schedules"
    df = pd.read_sql(query, conn)

    # Pivot for Heatmap (Route vs Station)
    # We'll look at the top 20 routes for clarity
    top_routes = df.groupby('route_id')['delay_min'].mean().nlargest(20).index
    df_filtered = df[df['route_id'].isin(top_routes)]

    pivot_table = df_filtered.pivot_table(
        index='route_id', columns='station_id', values='delay_min', aggfunc='mean')

    # Plot
    plt.figure(figsize=(12, 8))
    sns.heatmap(pivot_table, cmap="YlOrRd", annot=False)
    plt.title("Transit Delay Network Analysis (100,000 Samples)")
    plt.xlabel("Station ID")
    plt.ylabel("Route ID")

    plt.savefig("delay_heatmap.png")
    print("Heatmap generated: delay_heatmap.png")
    conn.close()


if __name__ == "__main__":
    generate_heatmap()
