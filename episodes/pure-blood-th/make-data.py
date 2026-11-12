# Builds data.json for the pure-blood episode.
# The rows below are the exact output of data.sql query 1, run on Querious (dataset harry_potter_wiki_characters, v20210514)
# on 2026-11-12, packed as id|house|status|name. house: G S R H = Hogwarts houses, O = other school, - = none.
# status: P = Pure-blood, H = Half-blood, M = Muggle-born, - = anything else (uncertain, blank, Muggle, Squib, part-human ...).
# usage: python3 episodes/pure-blood-th/make-data.py
import json, os
here = os.path.dirname(os.path.abspath(__file__))
RAW = """
1|G|H|Harry James Potter
2|G|P|Ronald Bilius Weasley
3|G|M|Hermione Jean Granger
4|G|H|Albus Percival Wulfric Brian Dumbledore
5|G|-|Rubeus Hagrid
6|G|P|Neville Longbottom
7|G|P|Fred Weasley
8|G|P|George Weasley
9|G|P|Ginevra (Ginny) Molly Weasley
10|G|M|Dean Thomas
11|G|H|Seamus Finnigan
12|G|M|Lily J. Potter
13|G|P|James Potter
14|G|P|Sirius Black
15|G|H|Remus John Lupin
16|G|-|Peter Pettigrew
17|G|P|Percy Ignatius Weasley
18|G|P|(Bill) William Arthur Weasley
19|G|P|Charles Weasley
20|G|-|Lee Jordan
21|G|-|Oliver Wood
22|G|-|Angelina Johnson
23|G|-|Katie Bell
24|G|-|Alicia Spinnet
25|G|P|Lavender Brown
26|G|-|Parvati Patil
27|G|-|Romilda Vane
28|G|M|Colin Creevey
29|G|-|Cormac McLaggen
30|G|H|Minerva McGonagall
31|G|P|Molly Weasley
32|G|P|Arthur Weasley
33|R|H|Quirinus Quirrell
34|R|-|Cho Chang
35|R|-|Luna Lovegood
36|R|H|Gilderoy Lockhart
37|R|-|Filius Flitwick
38|R|H|Sybill Patricia Trelawney
39|R|H|Garrick Ollivander
40|R|M|Myrtle Elizabeth Warren (Moaning Myrtle)
41|R|-|Padma Patil
42|R|H|Michael Corner
43|R|-|Marietta Edgecombe
44|R|-|Terry Boot
45|R|H|Anthony Goldstein
46|S|H|Severus Snape
47|S|P|Draco Malfoy
48|S|P|Vincent Crabbe
49|S|P|Gregory Goyle
50|S|P|Bellatrix Lestrange
51|S|H|Dolores Jane Umbridge
52|S|-|Horace Eugene Flaccus Slughorn
53|S|P|Lucius Malfoy
54|S|P|Narcissa Malfoy
55|S|P|Regulus Arcturus Black
56|S|-|Pansy Parkinson
57|S|-|Blaise Zabini
58|S|H|Tom Marvolo Riddle
59|S|P|Theodore Nott
60|S|P|Rodolphus Lestrange
61|S|H|Millicent Bulstrode
62|S|-|Graham Montague
63|S|-|Bloody Baron
64|S|-|Marcus Flint
65|R|-|Penelope Clearwater
66|R|-|Roger Davies
67|R|-|Marcus Belby
68|S|P|Salazar Slytherin
69|G|-|Godric Gryffindor
70|R|-|Rowena Ravenclaw
71|G|-|Nicholas de Mimsy-Porpington
72|-|-|Cuthbert Binns
73|-|-|Barty Crouch Jr.
74|-|-|Charity Burbage
75|-|-|Firenze
76|S|-|Alecto Carrow
77|S|-|Amycus Carrow
78|H|-|Helga Hufflepuff
79|H|-|Fat Friar
80|R|-|Helena Ravenclaw
81|H|H|Nymphadora Tonks
82|H|-|Pomona Sprout
83|H|-|Newton Scamander
84|H|P|Cedric Diggory
85|H|M|Justin Finch-Fletchley
86|H|-|Zacharias Smith
87|H|H|Hannah Abbott
88|H|P|Ernest Macmillan
89|H|H|Susan Bones
90|S|-|Walden Macnair
91|S|-|Augustus Rookwood
92|S|-|Antonin Dolohov
93|S|-|Corban Yaxley
94|-|-|Igor Karkaroff
95|-|P|Kingsley Shacklebolt
96|-|P|Alastor Moody
97|-|P|Alice Longbottom
98|G|P|Frank Longbottom
99|-|-|Rufus Scrimgeour
100|-|-|Cornelius Oswald Fudge
101|-|P|Barty Crouch Sr.
102|-|-|Amos Diggory
103|-|-|Dedalus Diggle
104|-|P|Elphias Doge
105|O|-|Fleur Isabelle Delacour
106|-|H|Aberforth Dumbledore
107|-|H|Mundungus Fletcher
108|-|-|Sturgis Podmore
109|-|-|Hestia Jones
110|-|-|Marlene McKinnon
111|-|P|Fabian Prewett
112|-|P|Gideon Prewett
113|-|-|Emmeline Vance
114|H|-|Edgar Bones
115|-|-|Dorcas Meadowes
116|-|-|Benjy Fenwick
117|O|-|Madame Olympe Maxime
118|O|-|Gabrielle Delacour
119|O|-|Viktor Krum
120|-|-|Petunia Dursley
121|-|-|Vernon Dursley
122|-|-|Dudley Dursley
123|-|-|Marge Dursley
124|G|M|Dennis Creevey
125|S|H|Albus Severus Potter
126|S|P|Scorpius Hyperion Malfoy
127|H|H|Edward Remus Lupin
128|G|H|James Sirius Potter
129|G|H|Rose Granger-Weasley
130|-|-|Argus Filch
131|-|-|Poppy Pomfrey
132|-|-|Rolanda Hooch
133|-|-|Irma Pince
134|-|-|Aurora Sinistra
135|-|-|Septima Vector
136|-|-|Wilhelmina Grubbly-Plank
137|-|-|Fenrir Greyback
138|-|-|Gellert Grindelwald
139|-|-|Dobby
140|-|-|Kreacher
"""
chars = []
for line in RAW.strip().splitlines():
    i, h, s, n = line.split('|', 3)
    chars.append({'id': int(i), 'house': None if h == '-' else h, 'status': None if s == '-' else s, 'name': n})
# Query 2 = the query shown on screen (rows exactly as Querious returned them)
result = [
    ['Gryffindor', 'Half-blood', 7], ['Gryffindor', 'Muggle-born', 5], ['Gryffindor', 'Pure-blood', 14],
    ['Hufflepuff', 'Half-blood', 4], ['Hufflepuff', 'Muggle-born', 1], ['Hufflepuff', 'Pure-blood', 2],
    ['Ravenclaw', 'Half-blood', 6], ['Ravenclaw', 'Muggle-born', 1],
    ['Slytherin', 'Half-blood', 5], ['Slytherin', 'Pure-blood', 11]]
# checks against the script
conf = [c for c in chars if c['status']]
withh = [c for c in conf if c['house'] in ('G', 'S', 'R', 'H')]
assert len(chars) == 140 and len(conf) == 65 and len(withh) == 56
tab = {}
for c in withh: tab[(c['house'], c['status'])] = tab.get((c['house'], c['status']), 0) + 1
full = {'G': 'Gryffindor', 'S': 'Slytherin', 'R': 'Ravenclaw', 'H': 'Hufflepuff'}
st = {'P': 'Pure-blood', 'H': 'Half-blood', 'M': 'Muggle-born'}
assert sorted([full[h], st[s], n] for (h, s), n in tab.items()) == sorted(result)
weas = [c['name'] for c in withh if c['house'] == 'G' and c['status'] == 'P' and 'Weasley' in c['name']]
assert len(weas) == 9
json.dump({'chars': chars, 'result': result}, open(os.path.join(here, 'data.json'), 'w'), ensure_ascii=False)
print('ok', {f'{h}{s}': n for (h, s), n in sorted(tab.items())})
