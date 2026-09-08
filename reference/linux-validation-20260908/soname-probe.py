import ctypes, json
pairs=[('libsqlite3.so', 'libsqlite3.so.0'), ('libcairo.so', 'libcairo.so.2'), ('libyaml.so', 'libyaml-0.so.2'), ('libsnappy.so', 'libsnappy.so.1'), ('libgio-2.0.so', 'libgio-2.0.so.0'), ('libmagic.so', 'libmagic.so.1'), ('libzmq.so', 'libzmq.so.5'), ('libpq.so', 'libpq.so.5'), ('libudis86.so', 'libudis86.so.0'), ('libblas.so', 'libblas.so.3'), ('libgtk-x11-2.0.so', 'libgtk-x11-2.0.so.0'), ('libgtk-3.so', 'libgtk-3.so.0')]
results=[]
for pair in pairs:
 row={}
 for lib in pair:
  try: ctypes.CDLL(lib); row[lib]=True
  except OSError as e: row[lib]=str(e)
 results.append(row)
print(json.dumps(results,indent=2))
assert all(r[p[1]] is True for p,r in zip(pairs,results))
