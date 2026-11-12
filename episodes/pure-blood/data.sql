-- Pure-blood episode. Dataset (Querious table name = dataset id):
--   harry_potter_wiki_characters (Harry Potter Wiki via Kaggle, v20210514, CC BY-SA 3.0) 140 characters
-- Run on Querious 2026-11-12. make-data.py holds the returned rows and checks the counts.
-- "Clear" blood status = exactly Pure-blood, Half-blood or Muggle-born (65 of 140). Excluded: "Pure-blood or half-blood" and
-- similar, blank, Unknown, Muggle, Squib, Quarter-Veela, Part-Goblin, Part-Human. 9 of the 65 have no house, which leaves 56.

-- 1. every character with house and clear status (grid of 140)
SELECT character_id AS id, name, house, blood_status,
  CASE WHEN blood_status IN ('Pure-blood','Half-blood','Muggle-born') THEN blood_status END AS status
FROM harry_potter_wiki_characters ORDER BY character_id;

-- 2. result: the query shown on screen (the user's query, with an alias and ORDER BY added)
SELECT house, blood_status, count(character_id) AS n
FROM harry_potter_wiki_characters
WHERE blood_status IN ('Half-blood', 'Pure-blood', 'Muggle-born')
  AND house IS NOT NULL
GROUP BY house, blood_status
ORDER BY house, blood_status;
