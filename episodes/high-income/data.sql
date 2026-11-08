-- high-income: data for the scene (querios catalog, version 20261008), run 2026-11-08
-- Datasets:
--   worldbank_income_classification_history  (official OGHIST group per country and GNI data year, 1987–2025)
--   worldbank_income_classification_thresholds (high-income line = High income gni_per_capita_min_usd − 1)
--   worldbank_gni_per_capita_atlas            (GNI per capita, Atlas method, current US$; WDI NY.GNP.PCAP.CD)
-- Counting rule: a move up = official group 'H' this data year, not 'H' in the previous classified year.
-- Countries only: territories PRI ABW MAC GUM MNP NCL IMN GIB ASM are left out of the counts (shown in the note).
-- Charts of Korea and Argentina use the official groups, not current GNI: current GNI estimates are revised,
-- e.g. Korea 1998–2000 and Argentina 2013/2015/2018/2025 sit above the line today but were not 'H' when classified.

-- 1) Shown on screen: every move up into high income (64 rows incl. territories and repeats)
SELECT country_name, year
FROM (
  SELECT country_name, year, income_group_code AS grp,
    LAG(income_group_code) OVER (
      PARTITION BY country_iso_alpha3 ORDER BY year) AS prev
  FROM worldbank_income_classification_history
  WHERE income_group_code IS NOT NULL
)
WHERE grp = 'H' AND prev <> 'H'
ORDER BY year, country_name;

-- 2) Moves up / down per year, first move per country, latest group (the scene's bar chart, map order, 32 of 36)
WITH c AS (
  SELECT country_iso_alpha3 AS iso, year, income_group_code = 'H' AS hi,
    LAG(income_group_code = 'H') OVER (PARTITION BY country_iso_alpha3 ORDER BY year) AS prev
  FROM worldbank_income_classification_history
  WHERE income_group_code IS NOT NULL
)
SELECT iso, year, CASE WHEN hi THEN 'up' ELSE 'down' END AS move
FROM c
WHERE hi <> prev
  AND iso NOT IN ('PRI','ABW','MAC','GUM','MNP','NCL','IMN','GIB','ASM')
ORDER BY year, iso;

-- 3) High-income line by data year
SELECT year, gni_per_capita_min_usd - 1 AS line
FROM worldbank_income_classification_thresholds
WHERE income_group_order = 4
ORDER BY year;

-- 4) GNI per capita (Guyana 2015–2025, Korea 2025) and Thailand / China as % of the line, 2011–2025
SELECT g.country_iso_alpha3, g.year, g.gni_per_capita_atlas_usd,
  ROUND(100 * g.gni_per_capita_atlas_usd / (t.gni_per_capita_min_usd - 1), 1) AS pct_of_line
FROM worldbank_gni_per_capita_atlas g
JOIN worldbank_income_classification_thresholds t ON t.year = g.year AND t.income_group_order = 4
WHERE g.country_iso_alpha3 IN ('GUY','KOR','THA','CHN') AND g.year >= 2011
ORDER BY 1, 2;

-- 5) How many of the 36 were high income each year (the cumulative column chart; 3 in 1988 → 32 in 2025, falls 2015–16 and 2020)
SELECT year, COUNT(*) FILTER (WHERE income_group_code = 'H') AS n_high
FROM worldbank_income_classification_history
WHERE country_iso_alpha3 IN ('CYP','BRB','MLT','PRT','KOR','GRC','SVN','BHR','ATG','SAU','CZE','EST','TTO','GNQ','HUN','OMN',
  'SVK','HRV','LVA','POL','KNA','CHL','LTU','RUS','URY','ARG','SYC','VEN','PLW','PAN','MUS','NRU','ROU','GUY','BGR','CRI')
  AND year >= 1988
GROUP BY year ORDER BY year;
