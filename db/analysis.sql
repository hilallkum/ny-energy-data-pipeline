
-- Trend, Correlation & Results

-- 1) Create Final Fact Table
DROP TABLE IF EXISTS processed_ny.fact_ny_month_final;

CREATE TABLE processed_ny.fact_ny_month_final AS
SELECT
    year,
    month,
    total_energy_value,
    total_accounts,
    avg_tmax,
    avg_tmin,
    sum_prcp,
    total_population_ny,
    energy_per_capita
FROM processed_ny.fact_ny_month;

-- 2) Index for performance
CREATE INDEX IF NOT EXISTS idx_fact_final_year_month
ON processed_ny.fact_ny_month_final(year, month);

-- 3) Trend Analysis
SELECT year, month, energy_per_capita, avg_tmax, sum_prcp
FROM processed_ny.fact_ny_month_final
ORDER BY year, month;

-- 4) Correlation Analysis
SELECT
    CORR(energy_per_capita, avg_tmax) AS corr_epc_tmax,
    CORR(energy_per_capita, sum_prcp) AS corr_epc_prcp
FROM processed_ny.fact_ny_month_final
WHERE energy_per_capita IS NOT NULL
  AND avg_tmax IS NOT NULL
  AND sum_prcp IS NOT NULL;

-- 5) Store Correlation Results
DROP TABLE IF EXISTS processed_ny.results_metrics;

CREATE TABLE processed_ny.results_metrics AS
SELECT 'corr_epc_tmax' AS metric, CORR(energy_per_capita, avg_tmax) AS value
FROM processed_ny.fact_ny_month_final
WHERE energy_per_capita IS NOT NULL AND avg_tmax IS NOT NULL

UNION ALL

SELECT 'corr_epc_prcp', CORR(energy_per_capita, sum_prcp)
FROM processed_ny.fact_ny_month_final
WHERE energy_per_capita IS NOT NULL AND sum_prcp IS NOT NULL;

SELECT * FROM processed_ny.results_metrics;

-- 6) Store Regression Model Summary
DROP TABLE IF EXISTS processed_ny.model_results;

CREATE TABLE processed_ny.model_results AS
SELECT 'OLS_Energy_Climate_Model' AS model_name, 0.662 AS r_squared, 0.589 AS adj_r_squared;



SELECT COUNT(*) 
FROM processed_ny.fact_ny_month_final;

SELECT * 
FROM processed_ny.results_metrics;


SELECT * FROM processed_ny.model_results;
