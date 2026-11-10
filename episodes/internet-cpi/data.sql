-- How data.json was produced (run with DuckDB from the root of the querios repo, via make-data.py).
-- Datasets (Querious table names = dataset ids):
--   worldbank_internet_users_pct_population   (WDI IT.NET.USER.ZS, source ITU, v20261008) % of population using the Internet
--   transparency_corruption_perceptions_index (Transparency International CPI 2025, comparable 2012–2025 scores, v20260210) 0 = highly corrupt, 100 = very clean
-- Years 2012–2024: 2025 has internet values for only 10 CPI countries, so it is left out.
CREATE VIEW worldbank_internet_users_pct_population AS
SELECT * FROM 'data/worldbank/internet_users_pct_population/20261008/processed/internet_users_pct_population.parquet';
CREATE VIEW transparency_corruption_perceptions_index AS
SELECT * FROM 'data/transparency_international/corruption_perceptions_index/20260210/processed/corruption_perceptions_index.parquet';
CREATE VIEW both_ AS
SELECT c.country_iso_alpha3 AS iso, c.country_name AS name, c.year,
       i.internet_users_pct_population AS net, c.cpi_score AS cpi
FROM transparency_corruption_perceptions_index c
JOIN worldbank_internet_users_pct_population i
  ON c.country_iso_alpha3 = i.country_iso_alpha3 AND c.year = i.year
WHERE c.cpi_score IS NOT NULL AND i.internet_users_pct_population IS NOT NULL;

-- 1. yearly: correlation and simple averages of countries with both values
SELECT year, count(*) AS n, round(corr(net, cpi), 3) AS r,
       round(avg(net), 1) AS avg_net, round(avg(cpi), 1) AS avg_cpi
FROM both_ WHERE year BETWEEN 2012 AND 2024 GROUP BY year ORDER BY year;

-- 2. points: every country with both values, 2012 and 2024 (172 and 167 countries)
SELECT year, iso, name, round(net, 1) AS net, cpi FROM both_ WHERE year IN (2012, 2024) ORDER BY year, iso;

-- 3. the 90%+ online club: 6 countries in 2012 (CPI 80–90), 50 in 2024 (CPI 22–90)
SELECT year, count(*) AS n, min(cpi) AS min_cpi, max(cpi) AS max_cpi
FROM both_ WHERE year IN (2012, 2024) AND net >= 90 GROUP BY year;

-- 4. change 2012 → 2024 per country (163 countries): r(Δnet, ΔCPI) = 0.14, CPI down in 84, up in 72
SELECT count(*) AS n, round(corr(b.net - a.net, b.cpi - a.cpi), 3) AS r_change,
       sum((b.cpi < a.cpi)::int) AS cpi_down, sum((b.cpi > a.cpi)::int) AS cpi_up
FROM both_ a JOIN both_ b ON a.iso = b.iso AND a.year = 2012 AND b.year = 2024;

-- 5. result: the query shown on screen
SELECT c.year,
  round(corr(i.internet_users_pct_population,
             c.cpi_score), 2) AS r
FROM transparency_corruption_perceptions_index c
JOIN worldbank_internet_users_pct_population i
  ON c.country_iso_alpha3 = i.country_iso_alpha3
 AND c.year = i.year
WHERE c.year <= 2024
GROUP BY c.year ORDER BY c.year;
