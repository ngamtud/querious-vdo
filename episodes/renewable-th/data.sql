-- How data.json was produced (run with DuckDB from the root of the querios repo).
-- Datasets (Querious table names = dataset ids):
--   worldbank_renewable_energy_consumption_pct      (WDI EG.FEC.RNEW.ZS, v20261008) % of final energy consumption
--   worldbank_electric_power_consumption_per_capita (WDI EG.USE.ELEC.KH.PC, v20261008) kWh per person
--   country_geography                               (UN M49, v20261005) regions
-- Year 2021: last year with full coverage (2022 has 71 of 215 values and no DR Congo; 2023-2025 are null).
CREATE VIEW worldbank_renewable_energy_consumption_pct AS
SELECT * FROM 'data/worldbank/renewable_energy_consumption_pct/20261008/processed/renewable_energy_consumption_pct.parquet';
CREATE VIEW worldbank_electric_power_consumption_per_capita AS
SELECT * FROM 'data/worldbank/electric_power_consumption_per_capita/20261008/processed/electric_power_consumption_per_capita.parquet';
CREATE VIEW country_geography AS
SELECT * FROM 'data/un/m49_country_geography/20261005/processed/country_geography.parquet';

-- 1. regions: simple (unweighted) average of country values, 2021
SELECT g.un_m49_region_name AS region, count(*) AS n,
       round(avg(r.renewable_energy_consumption_pct), 1) AS avg_pct
FROM worldbank_renewable_energy_consumption_pct r
JOIN country_geography g USING (country_iso_alpha3)
WHERE r.year = 2021 AND r.renewable_energy_consumption_pct IS NOT NULL
GROUP BY 1 ORDER BY avg_pct DESC;

-- 2. top: highest renewable share, 2021
SELECT country_iso_alpha3 AS iso, country_name AS name, renewable_energy_consumption_pct AS pct
FROM worldbank_renewable_energy_consumption_pct
WHERE year = 2021 ORDER BY pct DESC NULLS LAST LIMIT 3;

-- 3. points: renewable share vs electricity per person, 2021 (149 countries with both)
SELECT r.country_iso_alpha3 AS iso, r.country_name AS name, g.un_m49_region_name AS region,
       r.renewable_energy_consumption_pct AS pct,
       e.electric_power_consumption_kwh_per_capita AS kwh
FROM worldbank_renewable_energy_consumption_pct r
JOIN worldbank_electric_power_consumption_per_capita e USING (country_iso_alpha3, year)
JOIN country_geography g USING (country_iso_alpha3)
WHERE r.year = 2021 AND r.renewable_energy_consumption_pct IS NOT NULL
  AND e.electric_power_consumption_kwh_per_capita IS NOT NULL;
-- "both" ranking used on screen = pct/100 * kwh (rough lens: final-energy share × electricity use)

-- 4. finland: renewable share 1990-2021
SELECT year, renewable_energy_consumption_pct AS pct
FROM worldbank_renewable_energy_consumption_pct
WHERE country_iso_alpha3 = 'FIN' AND year BETWEEN 1990 AND 2021 ORDER BY year;

-- 5. result: the query shown on screen (first rows of its output; ranks by share x use)
SELECT r.country_name,
  r.renewable_energy_consumption_pct AS pct,
  e.electric_power_consumption_kwh_per_capita AS kwh
FROM worldbank_renewable_energy_consumption_pct r
JOIN worldbank_electric_power_consumption_per_capita e
  USING (country_iso_alpha3, year)
WHERE year = 2021
ORDER BY pct * kwh DESC NULLS LAST;
