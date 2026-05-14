-- =========================================================
-- 01_TABLES.SQL
-- Create raw tables and load CSV data
-- =========================================================

-- 1) ACS ZIP population
CREATE TABLE IF NOT EXISTS acs_zip_population (
  year INT NOT NULL,
  zip_code TEXT NOT NULL,
  zip_city TEXT,
  state_2 TEXT,
  population BIGINT,
  data_class TEXT,
  data_field_display_name TEXT,
  data_field TEXT,
  data_stream TEXT,
  PRIMARY KEY (year, zip_code)
);

-- 2) NOAA daily weather
DROP TABLE IF EXISTS weather;

CREATE TABLE weather (
    date DATE,
    tavg FLOAT,
    tmax FLOAT,
    tmin FLOAT,
    prcp FLOAT,
    snow FLOAT,
    snwd FLOAT,
    state VARCHAR(10)
);

COPY weather(date, tavg, tmax, tmin, prcp, snow, snwd, state)
FROM 'D:\semester 1\PAI\project\datasets\weather_data.csv'
DELIMITER ','
CSV HEADER;

-- 3) Energy merged monthly
DROP TABLE IF EXISTS energy_merged_monthly;

CREATE TABLE IF NOT EXISTS energy_merged_monthly (
  year INT,
  data_class TEXT,
  data_field_display_name TEXT,
  data_field TEXT,
  month INT,
  unit TEXT,
  uer_id TEXT,
  data_stream TEXT,
  utility_display_name TEXT,
  value NUMERIC,
  number_of_accounts NUMERIC,
  state_2 TEXT
);

-- Load County Energy CSV
COPY energy_merged_monthly(
  year, data_class, data_field_display_name, data_field, month,
  unit, uer_id, data_stream, utility_display_name, value,
  number_of_accounts, state_2
)
FROM 'D:\semester 1\PAI\project\datasets\Utility_Energy_Registry_Monthly_County_Energy_Use__2016-2021.csv'
WITH (FORMAT csv, HEADER true);

-- Load ZIP Energy CSV
COPY energy_merged_monthly(
  year, data_class, data_field_display_name, data_field, month,
  unit, uer_id, data_stream, utility_display_name, value,
  number_of_accounts, state_2
)
FROM 'D:\semester 1\PAI\project\datasets\Utility_Energy_Registry_Monthly_ZIP_Code_Energy_Use__Beginning_2021.csv'
WITH (FORMAT csv, HEADER true);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_acs_year_zip
ON acs_zip_population(year, zip_code);

CREATE INDEX IF NOT EXISTS idx_weather_date_state
ON weather(date, state);

CREATE INDEX IF NOT EXISTS idx_energy_year_month
ON energy_merged_monthly(year, month);

-- Sample check
SELECT * FROM energy_merged_monthly
WHERE year = 2016 AND month = 12;

-- Raw table checks
SELECT * FROM acs_zip_population;
SELECT * FROM weather;
SELECT * FROM energy_merged_monthly;

-- Row counts
SELECT 'acs_zip_population' AS table_name, COUNT(*) FROM acs_zip_population
UNION ALL
SELECT 'weather', COUNT(*) FROM weather
UNION ALL
SELECT 'energy_merged_monthly', COUNT(*) FROM energy_merged_monthly;
