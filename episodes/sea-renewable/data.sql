-- How data.json was produced (run on Querious, or with DuckDB from the root of the querios repo using the views below).
-- Datasets (Querious table names = dataset ids):
--   worldbank_renewable_energy_consumption_pct      (WDI EG.FEC.RNEW.ZS, v20261008) % of final energy consumption
--   worldbank_electric_power_consumption_per_capita (WDI EG.USE.ELEC.KH.PC, v20261008) kWh per person
--   country_geography                               (UN M49, v20261005) South-eastern Asia = 11 countries
-- Year 2021: last year with renewable data for every country in the region (2022 is mostly null).
-- Baseline: 1990, or each country's first year on record (Cambodia 1995, Timor-Leste 2002).
CREATE VIEW worldbank_renewable_energy_consumption_pct AS
SELECT * FROM 'data/worldbank/renewable_energy_consumption_pct/20261008/processed/renewable_energy_consumption_pct.parquet';
CREATE VIEW worldbank_electric_power_consumption_per_capita AS
SELECT * FROM 'data/worldbank/electric_power_consumption_per_capita/20261008/processed/electric_power_consumption_per_capita.parquet';
CREATE VIEW country_geography AS
SELECT * FROM 'data/un/m49_country_geography/20261005/processed/country_geography.parquet';

-- 1. slope: first year on record vs 2021, South-eastern Asia (10 fell, Singapore rose)
WITH r AS (SELECT country_iso_alpha3 AS iso, year, renewable_energy_consumption_pct AS pct
           FROM worldbank_renewable_energy_consumption_pct
           WHERE renewable_energy_consumption_pct IS NOT NULL AND year <= 2021),
     f AS (SELECT iso, min(year) AS y0 FROM r GROUP BY 1)
SELECT g.country_iso_alpha3 AS iso, g.country_name_un AS name, f.y0, a.pct AS p0, b.pct AS p21
FROM country_geography g
JOIN f ON f.iso = g.country_iso_alpha3
JOIN r a ON a.iso = f.iso AND a.year = f.y0
JOIN r b ON b.iso = f.iso AND b.year = 2021
WHERE g.un_m49_subregion_name = 'South-eastern Asia'
ORDER BY a.pct DESC;

-- 2. vnm / mys / tha: renewable share and electricity per person, 1990-2021
--    (Viet Nam: 98.9 -> 2,402.3 kWh = 24.3x; Malaysia low 2.0% in 2010; Thailand 19.0% in 2021 = lowest since 1990)
SELECT r.country_iso_alpha3 AS iso, r.year,
       round(r.renewable_energy_consumption_pct, 1) AS pct,
       round(e.electric_power_consumption_kwh_per_capita, 1) AS kwh
FROM worldbank_renewable_energy_consumption_pct r
JOIN worldbank_electric_power_consumption_per_capita e USING (country_iso_alpha3, year)
WHERE r.country_iso_alpha3 IN ('VNM', 'MYS', 'THA') AND r.year BETWEEN 1990 AND 2021
ORDER BY 1, 2;

-- 3. result: the query shown on screen (22 rows; first 6 shown)
SELECT g.country_name_un AS country,
  r.year,
  r.renewable_energy_consumption_pct AS pct,
  e.electric_power_consumption_kwh_per_capita AS kwh
FROM worldbank_renewable_energy_consumption_pct r
JOIN worldbank_electric_power_consumption_per_capita e
  USING (country_iso_alpha3, year)
JOIN country_geography g USING (country_iso_alpha3)
WHERE g.un_m49_subregion_name = 'South-eastern Asia'
  AND r.year IN (1990, 2021)
ORDER BY country, r.year;
