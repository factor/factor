import os,socket,subprocess,json,pathlib,urllib.request
expected_uid = int(os.environ.get("FIXTURE_CALLER_UID", str(os.getuid())))
assert os.getuid()==expected_uid
status=pathlib.Path('/proc/self/status').read_text()
assert all(int(x.split()[1],16)==0 for x in status.splitlines() if x.startswith('Cap'))
ss=[]
for family,addr in [(socket.AF_INET,('127.0.0.1',9000)),(socket.AF_INET6,('::1',9000))]:
 s=socket.socket(family); s.bind(addr); s.listen(); ss.append(s)
u=socket.socket(socket.AF_UNIX); u.bind('/tmp/factor-isolation-fixture.sock')
assert socket.getaddrinfo('localhost',80)
assert socket.getaddrinfo('www.google.se',443)
print('HTTPS',urllib.request.urlopen('https://www.google.se',timeout=30).status,flush=True)
source=pathlib.Path(__file__).parent/'source'
env=os.environ.copy();env['LD_LIBRARY_PATH']=str(source)+':'+env.get('LD_LIBRARY_PATH','')
r=subprocess.run([str(source/'factor'),'-no-user-init','-no-monitors','-resource-path='+str(source),'-e=USING: unix.ffi prettyprint ; getuid .'],env=env,capture_output=True,text=True,timeout=60)
print('FACTOR CHILD',r.returncode,repr(r.stdout),repr(r.stderr),flush=True)
assert r.returncode==0 and r.stdout.strip()==str(expected_uid)
print('fixture PASS',flush=True)

import time;time.sleep(5)
