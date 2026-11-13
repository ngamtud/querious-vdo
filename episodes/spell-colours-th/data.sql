-- Spell-colours episode. Dataset: harry_potter_wiki_spells (Harry Potter Wiki via Kaggle, v20210514, CC BY-SA 3.0), 301 spells
-- Run on Querious 2026-11-12. make-data.py holds the rows of query 1 and checks every count used in the script.
-- Families (mixed types assigned in this order): hex > jinx > curse/dark > transfiguration > charm (incl. counter-spells, healing) > other.
-- On screen and in query 2, "dark" = curses + hexes + jinxes; transfiguration and other spells are "other".

-- 1. every spell: family code + colour code (packed into make-data.py)
WITH s AS (
 SELECT row_number() OVER (ORDER BY name) i, name,
  CASE WHEN type ILIKE '%hex%' THEN 'H'
       WHEN type ILIKE '%jinx%' AND type<>'Counter-jinx' THEN 'J'
       WHEN regexp_matches(lower(type),'(^|, )curse') OR type IN ('Dark Arts','Dark charm') THEN 'C'
       WHEN type ILIKE '%transfig%' OR type IN ('Transformation','Untransfiguration','Vanishment') THEN 'T'
       WHEN type ILIKE '%charm%' OR type ILIKE '%counter%' OR type ILIKE '%healing%' THEN 'M'
       ELSE 'O' END f,
  CASE WHEN light IS NULL THEN 'n'
       WHEN lower(light) LIKE '% or %' OR lower(light) LIKE '%,%' OR lower(light) LIKE '% and %' THEN 'x'
       WHEN lower(light) LIKE 'none%' OR lower(light) LIKE 'invisible%' OR lower(light) LIKE 'crystal%' THEN '0'
       WHEN lower(light) LIKE '%white%' THEN 'w'
       WHEN lower(light) LIKE '%blu%' OR lower(light) LIKE '%turquoise%' THEN 'b'
       WHEN lower(light) LIKE '%green%' THEN 'g'
       WHEN lower(light) SIMILAR TO '.*(red|scarlet|crimson).*' THEN 'r'
       WHEN lower(light) SIMILAR TO '.*(purple|violet).*' THEN 'p'
       WHEN lower(light) LIKE '%orange%' OR lower(light)='fire' THEN 'o'
       WHEN lower(light) LIKE '%pink%' THEN 'k'
       WHEN lower(light) SIMILAR TO '.*(yellow|gold).*' THEN 'y'
       WHEN lower(light) SIMILAR TO '.*(grey|silver|smoke).*' THEN 's'
       ELSE 'q' END c
 FROM harry_potter_wiki_spells)
SELECT string_agg(f||c||'|'||name, '~' ORDER BY i) packed FROM s;

-- 2. the query shown on screen (same grouping, 11 rows)
SELECT colour,
  count(*) FILTER (WHERE grp = 'charm') AS charms,
  count(*) FILTER (WHERE grp = 'dark')  AS dark,
  count(*) AS spells
FROM (
  SELECT
    CASE WHEN type ILIKE '%hex%'
           OR (type ILIKE '%jinx%' AND type <> 'Counter-jinx')
           OR regexp_matches(lower(type), '(^|, )curse')
           OR type IN ('Dark Arts', 'Dark charm') THEN 'dark'
         WHEN type ILIKE '%transfig%' THEN 'other'
         WHEN regexp_matches(lower(type), 'charm|counter|healing') THEN 'charm'
         ELSE 'other' END AS grp,
    CASE WHEN light IS NULL THEN 'not recorded'
         WHEN regexp_matches(lower(light), ' or |,| and ') THEN 'mixed'
         WHEN regexp_matches(lower(light), '^(none|invisible|crystal)') THEN 'no light'
         WHEN regexp_matches(lower(light), 'white') THEN 'white'
         WHEN regexp_matches(lower(light), 'blu|turquoise') THEN 'blue'
         WHEN regexp_matches(lower(light), 'green') THEN 'green'
         WHEN regexp_matches(lower(light), 'red|scarlet|crimson') THEN 'red'
         WHEN regexp_matches(lower(light), 'purple|violet') THEN 'purple'
         WHEN regexp_matches(lower(light), 'orange|^fire$') THEN 'orange'
         WHEN regexp_matches(lower(light), 'pink') THEN 'pink'
         WHEN regexp_matches(lower(light), 'yellow|gold') THEN 'yellow'
         WHEN regexp_matches(lower(light), 'grey|silver|smoke') THEN 'grey'
         ELSE 'other' END AS colour
  FROM harry_potter_wiki_spells) AS s
WHERE colour NOT IN ('not recorded', 'no light')
GROUP BY colour
ORDER BY spells DESC;
-- result: blue 21/10/35 · white 13/4/23 · mixed 9/7/17 · green 9/6/16 · red 10/2/14 · orange 4/4/11 · purple 3/6/9 · grey 4/1/6 · yellow 3/2/5 · pink 3/1/5 · other 1/0/1
