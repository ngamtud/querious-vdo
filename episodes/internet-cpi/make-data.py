# Builds data.json from data.sql. usage (from repo root): .venv/bin/python episodes/internet-cpi/make-data.py /path/to/querios
import duckdb, json, os, sys
here = os.path.dirname(os.path.abspath(__file__))
os.chdir(sys.argv[1])
con = duckdb.connect()
stmts = [s.strip() for s in open(os.path.join(here, 'data.sql')).read().split(';') if s.strip()]
def rows(sql):
    cur = con.execute(sql); cols = [d[0] for d in cur.description]
    return [dict(zip(cols, r)) for r in cur.fetchall()]
q = []
for s in stmts:
    body = '\n'.join(l for l in s.splitlines() if not l.strip().startswith('--'))
    if body.strip().upper().startswith('CREATE'): con.execute(body)
    else: q.append(body)
yearly, pts, club, change, result = [rows(s) for s in q]
out = {'yearly': yearly,
       'p12': [{k: p[k] for k in ('iso', 'name', 'net', 'cpi')} for p in pts if p['year'] == 2012],
       'p24': [{k: p[k] for k in ('iso', 'name', 'net', 'cpi')} for p in pts if p['year'] == 2024],
       'club': club, 'change': change[0],
       'result': [{'year': r['year'], 'r': float(r['r'])} for r in result], 'resultRows': len(result)}
json.dump(out, open(os.path.join(here, 'data.json'), 'w'))
print(json.dumps({k: v for k, v in out.items() if k not in ('p12', 'p24')}, indent=0)[:2500]); print(len(out['p12']), len(out['p24']))
