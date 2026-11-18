-- How data.json was produced. Run on Querious (querious.studio, or the Querious connector), snapshot 20261118.
-- Datasets (Querious table names = dataset ids):
--   comtrade_thailand_e_waste_imports_by_partner   UN Comtrade, Thailand imports by partner, month and HS6 code (2012-01 to 2026-05)
--   hs_e_waste_codes                               HS codes and waste groups (battery waste is comparable across HS editions)
--   querious_timeline_events                       dated policy events (NCPO order 4/2559, 2020 e-waste import ban)
-- All tonnes are sums of partner rows. The World totals dataset is not used: it does not match the partner sums.
-- 2012-2021 = battery waste only (HS 854810). From 2022 = all 11 codes under HS 8549.
-- Weight is missing in some months, so tonnes undercount those months.

-- 1. battery: tonnes and partner countries per year, 2012-2021 (battery waste only in these years)
SELECT year(period_start) AS y, round(sum(net_weight_kg)/1e3, 1) AS tonnes, count(DISTINCT partner_name) AS partners
FROM comtrade_thailand_e_waste_imports_by_partner
WHERE year(period_start) BETWEEN 2012 AND 2021
GROUP BY 1 ORDER BY 1;

-- 2. all: every e-waste code (HS 2022), tonnes and US$ millions per year, 2022 to May 2026
SELECT year(period_start) AS y, round(sum(net_weight_kg)/1e3, 1) AS tonnes, round(sum(trade_value_usd)/1e6, 2) AS usd_m
FROM comtrade_thailand_e_waste_imports_by_partner
WHERE hs_version = 'H6'
GROUP BY 1 ORDER BY 1;

-- 3. top: the biggest sender by recorded weight each year, 2018-2025
SELECT year(period_start) AS y, partner_name, round(sum(net_weight_kg)/1e3, 1) AS tonnes
FROM comtrade_thailand_e_waste_imports_by_partner
WHERE year(period_start) BETWEEN 2018 AND 2025
GROUP BY 1, 2
QUALIFY row_number() OVER (PARTITION BY year(period_start) ORDER BY sum(coalesce(net_weight_kg, 0)) DESC) = 1
ORDER BY 1;

-- 4. usa2025: USA by waste group, 2025
SELECT c.waste_group, round(sum(p.net_weight_kg)/1e3, 1) AS tonnes
FROM comtrade_thailand_e_waste_imports_by_partner p
JOIN hs_e_waste_codes c ON p.hs_version = c.hs_version AND p.hs6 = c.hs6
WHERE p.partner_name = 'USA' AND year(p.period_start) = 2025
GROUP BY 1 ORDER BY 2 DESC;

-- 5. partners: countries sending battery waste per year (comparable across editions), plus all e-waste codes
SELECT year(p.period_start) AS y,
  count(DISTINCT CASE WHEN c.comparable_group = 'battery_waste' THEN p.partner_name END) AS battery_partners,
  count(DISTINCT p.partner_name) AS all_partners
FROM comtrade_thailand_e_waste_imports_by_partner p
JOIN hs_e_waste_codes c ON p.hs_version = c.hs_version AND p.hs6 = c.hs6
GROUP BY 1 ORDER BY 1;

-- 6. result: the query shown on screen (23 rows; the first 6 are shown)
SELECT partner_name,
  round(SUM(net_weight_kg) / 1000, 1) AS tonnes
FROM comtrade_thailand_e_waste_imports_by_partner
WHERE year(period_start) = 2025
GROUP BY partner_name
ORDER BY tonnes DESC NULLS LAST;
