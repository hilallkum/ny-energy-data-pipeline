# NY Energy Data Pipeline

A multi-stage data engineering pipeline analysing the socio-economic and environmental drivers of energy consumption in New York State, built on a hybrid MongoDB + PostgreSQL architecture.

## Overview

Urban energy data is fragmented across incompatible sources: structured utility registries, semi-structured government APIs, and high-volume weather streams. This project builds a end-to-end pipeline that ingests, transforms, and analyses all three using a "Polyglot Persistence" approach.

**Key finding:** Temperature and precipitation explain **66.2% of the variance** in per-capita energy demand (OLS R² = 0.662), with New York's grid showing a clear heating-dominant profile, winter peaks far exceed summer cooling loads.

## Architecture

```
ACS API (JSON)          →  MongoDB (NoSQL landing zone)
                                    ↓
NOAA Weather (CSV)      →  PostgreSQL (analytical layer)
Utility Registry (CSV)  →           ↓
                              ETL Pipeline (Python)
                                    ↓
                           Fact Table → Analysis & Visualisation
```

## Pipeline Stages

| Notebook | Description |
|---|---|
| `fetch_acs_to_mongo.ipynb` | Ingests ACS demographic data from API → MongoDB |
| `mongo_to_postgres_staging.ipynb` | Flattens nested JSON, migrates to PostgreSQL staging |
| `sql_analysis.ipynb` | Analytical queries, OLS regression, visualisations |

## Key Results

- **OLS R² = 0.662** — temperature variables explain 66% of energy demand variance (p < 0.001)
- **Heating-dominant grid** — January/February peaks significantly exceed summer cooling loads
- **Winter IQR** is the largest of any season, demand is least predictable during cold waves
- Per-capita normalisation separates climate sensitivity from population density effects

## Visualisations

Monthly energy consumption per capita:

![Monthly Energy](plots/monthly%20energy%20per%20capita.png)

Heating intensity vs energy consumption:

![Heating Intensity](plots/heating%20intensity%20vs%20epc.png)

Seasonal distribution:

![Seasonal](plots/seasonal%20distribution%20of%20epc.png)

## Stack

Python · MongoDB · PostgreSQL · Pandas · NumPy · Psycopg2 · Matplotlib · Seaborn · Statsmodels · SQL

## Data Sources

- [Utility Energy Registry — County Level](https://catalog.data.gov/dataset/utility-energy-registry-monthly-county-energy-use-beginning-2016) — NY State Dept of Public Service
- [NOAA Weather Data](https://www.ncei.noaa.gov/access/past-weather/new%20york) — National Centers for Environmental Information
- [ACS Demographic Data](https://catalog.data.gov/dataset/population-estimates-population-estimates) — U.S. Census Bureau

Download datasets and place in `datasets/raw_data/`.

## Collaboration

Built in collaboration with [Abdul Moiz](https://github.com/abdulmoiz21) and Muskan Lohana as part of the Programming for Artificial Intelligence module.

Hilal Tuana Kum — Climate dataset research and preparation (API and CSV-based), data cleaning and standardisation, time-series alignment across energy and population datasets, exploratory analysis, and visualisation suite. Also contributed to academic reporting and pipeline documentation.
Abdul Moiz & Muskan Lohana — Data ingestion pipeline (ACS API → MongoDB), ETL transformation, PostgreSQL staging, and SQL analysis.

