-- Epoch AI snapshot 2026-11-19. CC BY 4.0. Tables: epoch_ai_data_centers, epoch_ai_data_center_timelines.
-- IT power (MW) by owner for every day 2024-01-01 .. 2028-12-31.
-- Per site: linear between consecutive timeline milestones (the increase spread evenly per day),
-- 0 before the first milestone, held flat after the last. Sites with no owner are left out.
WITH m AS (
  SELECT data_center, CAST(date AS DATE) AS d, it_power_mw AS mw
  FROM epoch_ai_data_center_timelines
),
seg AS (
  SELECT data_center, d, mw,
         lead(d)  OVER w AS d2,
         lead(mw) OVER w AS mw2
  FROM m WINDOW w AS (PARTITION BY data_center ORDER BY d)
),
days AS (
  SELECT CAST(unnest(generate_series(DATE '2024-01-01', DATE '2028-12-31', INTERVAL 1 DAY)) AS DATE) AS day
),
v AS (
  SELECT day, data_center,
         CASE WHEN d2 IS NULL THEN mw
              ELSE mw + (mw2 - mw) * (day - d) / (d2 - d) END AS mw
  FROM days JOIN seg ON day >= d AND (d2 IS NULL OR day < d2)
)
SELECT regexp_replace(s.owner, ' #.*', '') AS owner, v.day, sum(v.mw) AS it_power_mw
FROM v JOIN epoch_ai_data_centers s USING (data_center)
WHERE s.owner IS NOT NULL
GROUP BY ALL
ORDER BY day, it_power_mw DESC;
