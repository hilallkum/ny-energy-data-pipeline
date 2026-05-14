-- Create NY-only processed tables and final monthly fact table

-- create schema
CREATE SCHEMA IF NOT EXISTS processed_ny;

-- cleaned population data
DROP TABLE IF EXISTS processed_ny.acs_clean;
CREATE TABLE processed_ny.acs_clean AS
SELECT
  year,
  LPAD(TRIM(zip_code), 5, '0') AS zip_code,
  'NY' AS state_2,
  population::bigint AS population,
  data_stream
FROM acs_zip_population
WHERE year BETWEEN 2021 AND 2025
  AND state_2 IN ('NY', 'New York')
  AND zip_code IS NOT NULL
  AND population IS NOT NULL
  AND TRIM(zip_code) ~ '^[0-9]{5}$'; -- remove corrupted ZIP

SELECT * FROM processed_ny.acs_clean;

-- cleaned energy data
DROP TABLE IF EXISTS processed_ny.energy_clean;
CREATE TABLE processed_ny.energy_clean AS
SELECT
  year,
  month,
  'NY' AS state_2,
  data_class,
  data_field_display_name,
  data_field,
  unit,
  uer_id,
  data_stream,
  utility_display_name,
  value::numeric AS value,
  number_of_accounts::numeric AS number_of_accounts
FROM energy_merged_monthly
WHERE year BETWEEN 2021 AND 2025
  AND month BETWEEN 1 AND 12
  AND state_2 = 'NY'
  AND value IS NOT NULL
  AND value::numeric >= 0; -- remove negative values

SELECT * FROM processed_ny.energy_clean
select * from energy_merged_monthly
LIMIT 5;

-- monthly weather aggregation for NY
DROP TABLE IF EXISTS processed_ny.weather_monthly;
CREATE TABLE processed_ny.weather_monthly AS
SELECT
  EXTRACT(YEAR FROM Date)::int AS year,
  EXTRACT(MONTH FROM Date)::int AS month,
  AVG(TMAX) AS avg_tmax,
  AVG(TMIN) AS avg_tmin,
  SUM(PRCP) AS sum_prcp,
  SUM(SNOW) AS sum_snow
FROM weather
WHERE State = 'NY'
  AND Date IS NOT NULL
  AND EXTRACT(YEAR FROM Date) BETWEEN 2021 AND 2025
GROUP BY 1, 2
ORDER BY 1, 2;

SELECT * FROM processed_ny.weather_monthly;

-- yearly population aggregation for NY
DROP TABLE IF EXISTS processed_ny.population_yearly;
CREATE TABLE processed_ny.population_yearly AS
SELECT
  year,
  SUM(population) AS total_population_ny
FROM processed_ny.acs_clean
GROUP BY year
ORDER BY year;

SELECT * FROM processed_ny.population_yearly;

-- final monthly fact table for analysis
DROP TABLE IF EXISTS processed_ny.fact_ny_month;
CREATE TABLE processed_ny.fact_ny_month AS
SELECT
  e.year,
  e.month,
  SUM(e.value) AS total_energy_value,
  SUM(e.number_of_accounts) AS total_accounts,
  w.avg_tmax,
  w.avg_tmin,
  w.sum_prcp,
  p.total_population_ny,
  CASE
    WHEN p.total_population_ny > 0
    THEN SUM(e.value) / p.total_population_ny
  END AS energy_per_capita
FROM processed_ny.energy_clean e
LEFT JOIN processed_ny.weather_monthly w
  ON w.year = e.year AND w.month = e.month
LEFT JOIN processed_ny.population_yearly p
  ON p.year = e.year
GROUP BY
  e.year, e.month, w.avg_tmax, w.avg_tmin, w.sum_prcp, p.total_population_ny
ORDER BY e.year, e.month;

SELECT COUNT(*) FROM processed_ny.fact_ny_month;
SELECT * FROM processed_ny.fact_ny_month

