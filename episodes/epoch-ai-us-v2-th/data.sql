-- Epoch AI snapshot 2026-11-19. CC BY 4.0.
-- Exact query shown in v2; future milestone peak minus current IT capacity.
SELECT s.data_center,
  MAX(t.it_power_mw) - s.current_it_power_mw AS extra_mw
FROM epoch_ai_data_centers s
JOIN epoch_ai_data_center_timelines t USING (data_center)
WHERE s.country = 'United States'
  AND CAST(t.date AS DATE) > DATE '2026-11-19'
GROUP BY s.data_center, s.current_it_power_mw
ORDER BY extra_mw DESC
LIMIT 3;

-- Scatter data; do not aggregate overlapping users.
SELECT data_center, current_it_power_mw AS mw,
       current_h100_equivalents AS compute
FROM epoch_ai_data_centers
WHERE country = 'United States'
  AND current_it_power_mw > 0 AND current_h100_equivalents > 0;
