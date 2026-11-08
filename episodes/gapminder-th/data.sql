-- How data.json was produced (run with DuckDB from the root of the querios repo).
-- Same join as the Querious challenge "Gapminder: Wealth and health of nations",
-- 1960–2023, exported as JSON records with columns year, iso, name, region, gdp, life, pop.
SELECT g.year, g.country_iso_alpha3 AS iso, g.country_name AS name,
       r.un_m49_region_name AS region,
       round(g.gdp_per_capita_current_usd, 2) AS gdp,
       round(l.life_expectancy_at_birth_years, 2) AS life,
       p.population_total AS pop
FROM 'data/worldbank/gdp_per_capita/20260128/processed/gdp_per_capita.parquet' g
JOIN 'data/worldbank/life_expectancy_at_birth/20261008/processed/life_expectancy_at_birth.parquet' l USING (country_iso_alpha3, year)
JOIN 'data/worldbank/population_total/20261008/processed/population_total.parquet' p USING (country_iso_alpha3, year)
JOIN 'data/un/m49_country_geography/20261005/processed/country_geography.parquet' r USING (country_iso_alpha3)
WHERE g.gdp_per_capita_current_usd IS NOT NULL
  AND l.life_expectancy_at_birth_years IS NOT NULL
  AND p.population_total IS NOT NULL
  AND g.year BETWEEN 1960 AND 2023
ORDER BY g.year;
