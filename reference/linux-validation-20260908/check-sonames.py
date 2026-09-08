import ctypes, json, pathlib
out=pathlib.Path(__file__).resolve().parent
checks=json.loads((out/'linux-sonames.json').read_text())
for file,library in checks:
 ctypes.CDLL(library)
 print('PASS',file,library)
