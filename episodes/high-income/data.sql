-- high-income: data for the scene, run on Querious (DuckDB) 2026-11-08
-- Dataset: worldbank_gdp_per_capita (GDP per capita, current US$, WDI 20260128) + country_geography (UN M49)
-- High-income line: World Bank GNI per capita (Atlas method) threshold by data year (1987–2024).
-- Note: the World Bank classifies by GNI (Atlas); this uses GDP per capita, so it is an approximation.
-- Iraq is excluded from the bar-chart counts (1990 $10,261, 1991 $23: data artifact around the Gulf War).

-- 1) Crossings up / down per year (also the query shown on screen)
WITH line AS (
  SELECT * FROM (VALUES (1987,6000),(1988,6000),(1989,6000),(1990,7620),(1991,7910),(1992,8355),(1993,8625),
    (1994,8955),(1995,9385),(1996,9655),(1997,9655),(1998,9360),(1999,9265),(2000,9265),(2001,9205),(2002,9075),
    (2003,9385),(2004,10065),(2005,10725),(2006,11115),(2007,11455),(2008,11905),(2009,12195),(2010,12275),
    (2011,12475),(2012,12615),(2013,12745),(2014,12735),(2015,12475),(2016,12235),(2017,12055),(2018,12375),
    (2019,12535),(2020,12695),(2021,13205),(2022,13845),(2023,14005),(2024,13935)) AS v(year, usd)
),
s AS (
  SELECT g.country_iso_alpha3 AS iso, g.country_name, g.year,
    g.gdp_per_capita_current_usd >= l.usd AS high
  FROM worldbank_gdp_per_capita g
  JOIN line l ON l.year = g.year
  WHERE g.gdp_per_capita_current_usd IS NOT NULL
),
c AS (SELECT *, LAG(high) OVER (PARTITION BY iso ORDER BY year) AS was_high FROM s)
SELECT iso, country_name, year, CASE WHEN high THEN 'up' ELSE 'down' END AS move
FROM c WHERE high <> was_high
ORDER BY year, country_name;

-- 2) Country lines (Argentina, South Korea, Guyana)
SELECT country_iso_alpha3 AS iso, year, ROUND(gdp_per_capita_current_usd) AS v
FROM worldbank_gdp_per_capita
WHERE country_iso_alpha3 IN ('ARG','KOR','GUY') AND year BETWEEN 1987 AND 2024
ORDER BY iso, year;

-- 3) Thailand and China as % of the line, 2011–2024 (line CTE as above)
-- SELECT g.country_iso_alpha3, g.year, ROUND(g.gdp_per_capita_current_usd / l.usd * 100, 1) AS pct
-- FROM worldbank_gdp_per_capita g JOIN line l ON l.year = g.year
-- WHERE g.country_iso_alpha3 IN ('THA','CHN') AND g.year BETWEEN 2011 AND 2024;

-- 4) Latest status of the 38 countries that crossed (33 above, 5 below: BRA, VEN, LBY, GNQ, NRU)
-- last non-null year per country compared with that year's line, joined to country_geography for region checks.
