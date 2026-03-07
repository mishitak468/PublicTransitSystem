CREATE DATABASE IF NOT EXISTS TransitSystem;

USE TransitSystem;

DROP TABLE IF EXISTS Schedule;

DROP TABLE IF EXISTS Stations;

CREATE TABLE Stations (
    station_id CHAR(1) PRIMARY KEY,
    station_name VARCHAR(100)
);

CREATE TABLE Schedule (
    id INT AUTO_INCREMENT PRIMARY KEY,
    route_id INT,
    station_id CHAR(1),
    arrival_time TIME NULL,
    departure_time TIME NULL,
    FOREIGN KEY (station_id) REFERENCES Stations (station_id)
) ENGINE = InnoDB;

INSERT INTO
    Stations
VALUES ('A', 'North Terminal'),
    ('B', 'Central Park'),
    ('C', 'Union Hub'),
    ('D', 'South Ferry'),
    ('E', 'West Side'),
    ('F', 'East Gate'),
    ('G', 'Industrial Zone'),
    ('Z', 'New Horizon Terminal');