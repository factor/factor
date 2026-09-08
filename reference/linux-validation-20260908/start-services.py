from pathlib import Path
import subprocess, time
out=Path(__file__).resolve().parent
pg=out/'postgres'
pg.mkdir(exist_ok=True)
(out/'pgsock').mkdir(exist_ok=True)
subprocess.run(['/usr/lib/postgresql/18/bin/initdb','-D',str(pg/'data'),'--encoding=UTF8','--locale=C','--auth=trust'],check=True,stdout=(pg/'init.log').open('w'),stderr=subprocess.STDOUT)
subprocess.run(['/usr/lib/postgresql/18/bin/pg_ctl','-D',str(pg/'data'),'-l',str(pg/'server.log'),'-o','-p 64578 -h 127.0.0.1 -k '+str(out/'pgsock'),'-w','start'],check=True)
subprocess.run(['redis-server','--bind','127.0.0.1','--port','64580','--save','','--appendonly','no','--daemonize','yes','--pidfile',str(out/'redis.pid'),'--logfile',str(out/'redis.log')],check=True)
p=subprocess.Popen(['Xvfb',':98','-screen','0','1280x1024x24','-nolisten','tcp'],stdout=(out/'xvfb.log').open('w'),stderr=subprocess.STDOUT,start_new_session=True)
(out/'xvfb.pid').write_text(str(p.pid))
time.sleep(1)
assert p.poll() is None, 'Xvfb failed; see xvfb.log'
