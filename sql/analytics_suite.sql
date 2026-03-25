-- Identify Bottlenecks
CREATE VIEW v_network_conflicts AS
SELECT
    route_id,
    station_id,
    arrival_time,
    actual_arrival_time,
    (
        actual_arrival_time - arrival_time
    ) AS delay_minutes,
    -- Looks at the next scheduled train at this specific station
    LEAD(arrival_time) OVER (
        PARTITION BY
            station_id
        ORDER BY arrival_time
    ) AS next_train_scheduled,
    CASE
        WHEN actual_arrival_time > LEAD(arrival_time) OVER (
            PARTITION BY
                station_id
            ORDER BY arrival_time
        ) THEN 'PLATFORM CONFLICT'
        ELSE 'BUFFER OK'
    END AS operational_impact
FROM transit_performance_logs;

-- Route Reliability Scorecard
SELECT
    route_id,
    AVG(delay_minutes) AS avg_delay,
    COUNT(
        CASE
            WHEN operational_impact = 'PLATFORM CONFLICT' THEN 1
        END
    ) AS conflict_count
FROM v_network_conflicts
GROUP BY
    route_id
ORDER BY avg_delay DESC;