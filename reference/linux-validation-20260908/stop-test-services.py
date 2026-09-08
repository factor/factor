import json, os, pathlib, signal, socket, subprocess, time
out=pathlib.Path(__file__).resolve().parent

def owned_process(pidfile, expected):
 pid=int(pidfile.read_text().splitlines()[0])
 cmd=pathlib.Path('/proc')/str(pid)/'cmdline'
 if not cmd.exists(): return None
 argv=cmd.read_bytes().replace(b'\0',b' ').decode()
 assert expected in argv, (pid, argv)
 return pid

if owned_process(out/'postgres/data/postmaster.pid',str(out/'postgres/data')):
 subprocess.run(['/usr/lib/postgresql/18/bin/pg_ctl','-D',str(out/'postgres/data'),'-m','fast','-w','stop'],check=True)
if owned_process(out/'redis.pid','127.0.0.1:64580'):
 subprocess.run(['redis-cli','-h','127.0.0.1','-p','64580','shutdown','nosave'],check=True)
pid=owned_process(out/'xvfb.pid','Xvfb :98 ')
if pid:
 os.kill(pid,signal.SIGTERM)
 deadline=time.monotonic()+10
 cmd=pathlib.Path('/proc')/str(pid)/'cmdline'
 while cmd.exists() and cmd.read_bytes():
  assert time.monotonic()<deadline, 'Xvfb did not stop'
  time.sleep(0.1)
for port in [64578,64580]:
 with socket.socket() as sock:
  sock.settimeout(2)
  assert sock.connect_ex(('127.0.0.1',port)) != 0, port
result={'postgresql_port_64578':'stopped','redis_port_64580':'stopped','xvfb_display_98':'stopped'}
(out/'services-stopped.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result))
