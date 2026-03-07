USE TransitSystem;

-- 1. MULTI-HOP PATHFINDING
-- Find a journey from North Station (A) to the New Destination (Z)
-- This involves finding a route that connects A to a hub, and a hub to Z.
SELECT
    leg1.route_id AS first_line,
    leg1.station_id AS start_node,
    leg2.station_id AS transfer_hub,
    leg2.route_id AS second_line,
    leg2.arrival_time AS final_arrival
FROM Schedule leg1
    JOIN Schedule leg2 ON leg1.station_id <> leg2.station_id
WHERE
    leg1.station_id = 'A'
    AND leg2.station_id = 'Z'
    AND leg1.route_id IN (
        SELECT route_id
        FROM Schedule
        WHERE
            station_id = leg2.station_id
    )
    AND leg2.arrival_time > leg1.departure_time;

-- 2. NETWORK CONGESTION ANALYSIS (Bottlenecks)
-- Identifies "Hotspots" where more than 2 different routes converge
SELECT
    s.station_id,
    st.station_name,
    COUNT(DISTINCT s.route_id) as route_count,
    GROUP_CONCAT(DISTINCT s.route_id) as lines_serving_station
FROM Schedule s
    JOIN Stations st ON s.station_id = st.station_id
GROUP BY
    s.station_id,
    st.station_name
HAVING
    route_count > 1
ORDER BY route_count DESC;

-- 3. SYSTEM SLACK CALCULATION
-- Calculates the "Layover" time at each station to find efficiency gaps
SELECT
    route_id,
    station_id,
    TIMEDIFF(departure_time, arrival_time) as idle_time
FROM Schedule
WHERE
    arrival_time IS NOT NULL
    AND departure_time IS NOT NULL;