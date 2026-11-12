-- How data.json was produced. Run on Querious (querious.studio, or the Querious connector), snapshot 20261111.
-- Datasets (Querious table names = dataset ids), all from Epoch AI, "Data on AI companies", CC BY 4.0:
--   epoch_ai_company_revenue_reports   reported revenue figures (annualized run rate / ARR, and period revenue)
--   epoch_ai_company_compute_spend     reported cloud compute spend (R&D and inference), OpenAI and Anthropic only
--   epoch_ai_company_funding_rounds    closed funding rounds (equity, debt, post-money valuation)
-- Most figures are media reports, not audited. Each row has a confidence rating and source URLs.

-- 1. lines: annualized revenue, full company, OpenAI and Anthropic
SELECT company, observation_date, annualized_revenue_usd / 1e9 AS rev_b, annualized_revenue_type, confidence
FROM epoch_ai_company_revenue_reports
WHERE company IN ('OpenAI', 'Anthropic') AND scope = 'Full company'
  AND annualized_revenue_usd IS NOT NULL AND observation_date >= '2023-12-31'
ORDER BY company, observation_date;

-- 2. result: the query shown on screen (2025 cloud compute spend vs revenue for the year)
SELECT c.company,
  round(sum(c.amount_usd)/1e9, 1) AS compute_b,
  round(max(r.period_revenue_usd)/1e9, 1) AS revenue_b
FROM epoch_ai_company_compute_spend c
JOIN epoch_ai_company_revenue_reports r
  ON r.company = c.company
 AND r.observation_date = c.observation_date
 AND r.period_type = 'Year'
WHERE c.observation_date = '2025-12-31'
GROUP BY c.company ORDER BY c.company;

-- 3. ratio2024: compute per dollar earned in 2024. Anthropic has a combined 2024 total (2.5B) that already
--    includes the 1.5B training row, so only the combined row is used. OpenAI has separate R&D and inference rows
SELECT c.company,
  round(sum(c.amount_usd) / max(r.period_revenue_usd), 2) AS compute_per_dollar
FROM epoch_ai_company_compute_spend c
JOIN epoch_ai_company_revenue_reports r
  ON r.company = c.company AND r.observation_date = c.observation_date AND r.period_type = 'Year'
WHERE c.observation_date = '2024-12-31'
  AND NOT (c.company = 'Anthropic' AND c.category = 'R&D cloud compute')
GROUP BY c.company ORDER BY c.company;

-- 4. funding: equity raised in closed rounds per year, all tracked companies
SELECT substr(close_date, 1, 4) AS yr, round(sum(funding_equity_usd)/1e9, 1) AS equity_b, count(*) AS n
FROM epoch_ai_company_funding_rounds
GROUP BY 1 ORDER BY 1;
