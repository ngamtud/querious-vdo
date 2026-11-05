-- How data.json was produced (run with DuckDB from the root of the querios repo).
-- Dataset: worldbank_fertility_rate_total (World Bank WDI SP.DYN.TFRT.IN, version 20261008).
-- In the Querious web app the table is named worldbank_fertility_rate_total.
CREATE VIEW worldbank_fertility_rate_total AS
SELECT * FROM 'data/worldbank/fertility_rate_total/20261008/processed/fertility_rate_total.parquet';

-- 1. series: Japan and Thailand, 1960-2024 (2025 is null for every area)
SELECT country_iso_alpha3 AS iso, year, fertility_rate_births_per_woman AS tfr
FROM worldbank_fertility_rate_total
WHERE country_iso_alpha3 IN ('JPN', 'THA') AND year BETWEEN 1960 AND 2024
ORDER BY iso, year;

-- 2. low: countries/territories with fertility at or below 1.3, per year, 1990-2024
SELECT year, count(*) FILTER (WHERE fertility_rate_births_per_woman <= 1.3) AS n
FROM worldbank_fertility_rate_total
WHERE year BETWEEN 1990 AND 2024
GROUP BY year ORDER BY year;

-- 3. chips: named examples in 2024
SELECT country_iso_alpha3 AS iso, country_name AS name, fertility_rate_births_per_woman AS tfr
FROM worldbank_fertility_rate_total
WHERE year = 2024 AND country_iso_alpha3 IN ('KOR', 'CHN', 'ESP', 'CHL');

-- 4. result: the query shown on screen (first rows of its output)
SELECT country_name, fertility_rate_births_per_woman
FROM worldbank_fertility_rate_total
WHERE year = 2024
ORDER BY 2;
