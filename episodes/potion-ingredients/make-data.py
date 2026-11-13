# Builds data.json for the potion-ingredients episode.
# P holds data.sql query 1 (every potion with a known ingredient list, harry_potter_wiki_potions v20210514, run on Querious 2026-11-13),
# with each ingredient reduced to a canonical name: same ingredient regardless of prep or quantity; aconite = wolfsbane;
# the source's "Vervain, infusion" counted as one item (vervain infusion); different animal parts kept apart.
# usage: python3 episodes/potion-ingredients/make-data.py
import json, os
from collections import Counter
here = os.path.dirname(os.path.abspath(__file__))
P={
'Ageing Potion':('Advanced',['bananas','newt spleens']),
'Babbling Beverage':(None,['dittany','wolfsbane','valerian']),
"Baruffio's Brain Elixir":(None,['dragon claw','runespoor eggs','frog brains','leaping toadstools']),
'Befuddlement Draught':(None,['sneezewort','lovage','scurvy grass']),
'Confusing Concoction':('Simple to moderate',['sneezewort','lovage','scurvy grass']),
'Cure for Boils':('Beginner',['shrake spines','ginger root','flobberworm mucus','pungous onions','nettles','snake fangs','horned slugs','porcupine quills']),
'Doxycide':(None,['cowbane','tormentil','hemlock','streeler shells','dragon liver','bundimun ooze']),
'Draught of Living Death':('Advanced',['sloth brain','sopophorous bean','valerian','wormwood','standard potioning water','asphodel']),
'Draught of Peace':('Advanced',['porcupine quills','unicorn horn','hellebore','moonstone']),
'Elixir of Life':(None,["philosopher's stone"]),
'Elixir to Induce Euphoria':('Advanced',['wormwood','sopophorous bean','peppermint','porcupine quills','shrivelfig']),
'Fake protective potions':('Beginner',['gravy','bubotuber pus']),
'Felix Felicis':('Advanced',['common rue','occamy eggshell','thyme','squill bulb','ashwinder egg','murtlap tentacle']),
'Fergus Fungal Budge':(None,['neem oil','jewelweed','onion juice']),
'Fire Protection Potion':('Beginner',['wartcap powder','salamander blood','bursting mushrooms']),
'Forgetfulness Potion':('Beginner',['mistletoe berries','standard ingredient','valerian','lethe river water']),
'Hair-Raising Potion':(None,['billywig stings','porcupine quills','rat tails']),
'Herbicide Potion':('Advanced',['standard ingredient','lionfish spines','horklump juice','flobberworm mucus']),
'Invigoration Draught':('O.W.L. level',['lovage','scurvy grass','honeywater','vervain infusion','wormwood','mandrake','peppermint','billywig stings','alihotsy leaves']),
'Laxative Potion':(None,['agrimonia','furnace ingredient (unknown)','unknown ingredient']),
'Love Potion Antidote':(None,['gurdyroot','castor oil','wiggentree twigs']),
'Mandrake Restorative Draught':(None,['mandrake']),
'Murtlap Essence':(None,['murtlap tentacle']),
'Pepperup Potion':(None,['mandrake','bicorn horn']),
'Polyjuice Potion':('Advanced',['hair of the person','boomslang skin','fluxweed','bicorn horn','knotgrass','leeches','lacewing flies']),
'Regeneration potion':('Advanced',['blood of a foe','flesh of a servant','bone of the father']),
'Rudimentary body potion':('Advanced',['unicorn blood','snake venom']),
'Shrinking Solution':(None,['wormwood','cowbane','leech juice','rat spleen','caterpillars','shrivelfig','daisy roots']),
'Skele-Gro':('Above second year',['scarab beetles','puffer-fish','chinese chomping cabbage']),
"Sleekeazy's Hair Potion":(None,['petroleum jelly','dragon hair','gomas barbadensis']),
'Sleeping Draught':('Advanced',['valerian','flobberworm mucus','standard ingredient','lavender']),
'Strengthening Solution':('Moderate to advanced',['griffin claw','salamander blood']),
'Swelling Solution':('Beginner',['bat spleens','nettles','puffer-fish eyes']),
'Tolipan Blemish Blitzer':(None,['dragon claw']),
'Truth serum':(None,['jobberknoll feathers']),
'Wideye Potion':('Beginner',['wolfsbane','billywig stings','standard ingredient','snake fangs']),
'Wit-Sharpening Potion':('Moderate',['armadillo bile','ginger root','scarab beetles']),
'Wolfsbane Potion':('Advanced',['wolfsbane']),
}

# prep notes and rare items quoted on screen (verbatim from the source list)
POLYJUICE_RAW = ["Lacewing flies (stewed 21 days)", "Leeches", "Powdered bicorn horn", "Knotgrass",
                 "Fluxweed (picked at full moon)", "Shredded Boomslang skin", "A bit of the person one wants to turn into (typically hair)"]
uses = Counter(i for d, l in P.values() for i in set(l))
dist = Counter(uses.values())
assert len(P) == 38 and sum(len(l) for d, l in P.values()) == 133 and len(uses) == 96
assert dict(dist) == {1: 73, 2: 13, 3: 6, 4: 4}
top = sorted([k for k, v in uses.items() if v == 4])
assert top == ['porcupine quills', 'standard ingredient', 'valerian', 'wormwood']
beg = {n: len(l) for n, (d, l) in P.items() if d == 'Beginner'}
adv = {n: len(l) for n, (d, l) in P.items() if d == 'Advanced'}
assert len(beg) == 6 and len(adv) == 11 and sum(beg.values()) / 6 == 4.0 and sum(adv.values()) / 11 == 4.0
assert beg['Cure for Boils'] == 8 and adv['Polyjuice Potion'] == 7 and adv['Wolfsbane Potion'] == 1
assert set(P['Befuddlement Draught'][1]) == set(P['Confusing Concoction'][1])
ings = [{'name': k, 'uses': v, 'potions': sorted(n for n, (d, l) in P.items() if k in l)} for k, v in sorted(uses.items(), key=lambda kv: (-kv[1], kv[0]))]
# query 2 = the query shown on screen
result = [['Advanced', 11, 4.0, 1, 7], ['Beginner', 6, 4.0, 2, 8]]
json.dump({'ingredients': ings, 'beginner': beg, 'advanced': adv, 'polyjuice': POLYJUICE_RAW,
           'twins': sorted(P['Befuddlement Draught'][1]), 'result': result}, open(os.path.join(here, 'data.json'), 'w'), ensure_ascii=False)
print('ok', dict(dist), top)
