-- production bable
DROP TABLE IF EXISTS schedules CASCADE;

CREATE TABLE schedules (
    id SERIAL PRIMARY KEY,
    route_id INT NOT NULL,
    station_id INT NOT NULL,
    scheduled TIMESTAMPTZ NOT NULL,
    actual TIMESTAMPTZ NOT NULL
);

-- error logging table
DROP TABLE IF EXISTS ingestion_errors;

CREATE TABLE ingestion_errors (
    error_id SERIAL PRIMARY KEY,
    raw_line_content TEXT,
    error_reason TEXT,
    detected_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- anomaly view
CREATE OR REPLACE VIEW v_transit_anomalies AS
SELECT *
FROM (
        SELECT *, AVG(
                EXTRACT(
                    EPOCH
                    FROM (actual - scheduled)
                ) / 60
            ) OVER (
                PARTITION BY
                    route_id
                ORDER BY scheduled ROWS BETWEEN 10 PRECEDING
                    AND CURRENT ROW
            ) as rolling_avg
        FROM (
                SELECT *, EXTRACT(
                        EPOCH
                        FROM (actual - scheduled)
                    ) / 60 as delay_min
                FROM schedules
            ) s
    ) a
WHERE
    delay_min > (rolling_avg * 2.5);