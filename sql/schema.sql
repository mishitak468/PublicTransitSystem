-- optimized schema
CREATE TABLE stations (
    station_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    lat DECIMAL(9, 6),
    lon DECIMAL(9, 6)
);

CREATE TABLE schedules (
    id SERIAL PRIMARY KEY,
    route_id INTEGER NOT NULL,
    station_id INTEGER REFERENCES stations (station_id),
    scheduled_arrival TIMESTAMPTZ NOT NULL,
    actual_arrival TIMESTAMPTZ,
    status VARCHAR(50) DEFAULT 'on-time'
);

-- indexing for high-performance lookups
CREATE INDEX idx_schedule_station ON schedules (station_id);

CREATE INDEX idx_schedule_arrival ON schedules (scheduled_arrival);