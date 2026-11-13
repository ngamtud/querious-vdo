-- Potion-ingredients episode. Dataset: harry_potter_wiki_potions (Harry Potter Wiki via Kaggle, v20210514, CC BY-SA 3.0), 72 potions
-- Run on Querious 2026-11-13. make-data.py holds the rows of query 1 (canonical names) and checks every count in the script.

-- 1. every ingredient of every potion that has a list (38 potions, 133 rows)
SELECT name, difficulty_level AS diff, trim(ing) AS ing
FROM harry_potter_wiki_potions, unnest(string_split(known_ingredients, ', ')) AS u(ing)
WHERE known_ingredients IS NOT NULL
ORDER BY name;

-- 2. the query shown on screen
SELECT difficulty_level,
       count(*) AS potions,
       avg(len(string_split(known_ingredients, ', '))) AS avg_ingredients,
       min(len(string_split(known_ingredients, ', '))) AS fewest,
       max(len(string_split(known_ingredients, ', '))) AS most
FROM harry_potter_wiki_potions
WHERE known_ingredients IS NOT NULL
  AND difficulty_level IN ('Beginner', 'Advanced')
GROUP BY difficulty_level
ORDER BY difficulty_level;
-- result: Advanced 11 · 4.0 · 1 · 7 / Beginner 6 · 4.0 · 2 · 8
