#!/usr/bin/env python3
import os
"""Reusable OpenBSD QEMU matrix runner; all SSH listeners bind localhost."""
import argparse,json,os,pathlib,shlex,subprocess,sys
p=argparse.ArgumentParser();p.add_argument('action',choices=['provision','boot','stop','ssh','build','test','status']);p.add_argument('arch',choices=['x86','x64','aarch64','i386','amd64','arm64']);p.add_argument('command',nargs=argparse.REMAINDER);p.add_argument('--assets',default=os.path.join(os.environ.get('FACTOR_QEMU_MATRIX_DIR',str(pathlib.Path(__file__).resolve().parents[2]/'work/qemu-matrix')),'openbsd'));a=p.parse_args()
arch={'x86':'i386','x64':'amd64','aarch64':'arm64'}.get(a.arch,a.arch);d=pathlib.Path(os.environ.get('OPENBSD_ASSETS',a.assets));d.mkdir(parents=True,exist_ok=True);port={'amd64':22400,'i386':22401,'arm64':22402}[arch];here=pathlib.Path(__file__).resolve().parent
ssh=['ssh','-o','StrictHostKeyChecking=no','-o','UserKnownHostsFile=/dev/null','-p',str(port),'root@127.0.0.1']
if a.action=='status':
 pid=d/(arch+'.pid');running=pid.exists() and pathlib.Path('/proc/'+pid.read_text().strip()).exists()
 print(json.dumps({'arch':arch,'running':running,'ssh_port':port,'assets':str(d)}));sys.exit(0 if running else 1)
if a.action=='provision':
 iso=d/(arch+'-install79.iso')
 if not iso.exists():subprocess.run(['curl','-fL','--retry','3','-o',str(iso),'https://cdn.openbsd.org/pub/OpenBSD/7.9/'+arch+'/install79.iso'],check=True)
 sys.exit(subprocess.call([sys.executable,str(here/'openbsd-install.py'),arch,'--assets',str(d),'--port',str(port)]))
if a.action=='stop':
 import signal
 os.kill(int((d/(arch+'.pid')).read_text()),signal.SIGTERM);sys.exit()
if a.action=='boot':
 cmd=['qemu-system-'+{'amd64':'x86_64','i386':'i386','arm64':'aarch64'}[arch],'-m','2048','-smp','1','-nographic','-drive',f'file={d}/{arch}.qcow2,format=qcow2,if=virtio','-netdev',f'user,id=n,hostfwd=tcp:127.0.0.1:{port}-:22','-device','virtio-net-pci,netdev=n']
 if arch=='arm64':cmd+=['-machine','virt','-cpu','cortex-a72','-bios','/usr/share/AAVMF/AAVMF_CODE.fd']
 elif arch=='i386':cmd+=['-accel','tcg','-cpu','max']
 else:cmd=['sg','kvm','-c',shlex.join(cmd+['-accel','kvm','-cpu','host'])]
 c=subprocess.Popen(cmd,stdin=subprocess.DEVNULL,stdout=open(d/(arch+'-boot.log'),'w'),stderr=subprocess.STDOUT,start_new_session=True);(d/(arch+'.pid')).write_text(str(c.pid));print(f'{arch}: SSH root@127.0.0.1:{port}, PID {c.pid}');sys.exit()
if a.action=='ssh':sys.exit(subprocess.call(ssh+[' '.join(a.command)]))
if a.action=='build':
 cfg={'amd64':'x86.64','i386':'x86.32','arm64':'arm.64'}[arch]
 sys.exit(subprocess.call(ssh+['cd /usr/local/factor; gmake -j2 factor factor-ffi-test CONFIG=vm/Config.openbsd.'+cfg+'; cp factor factor-cpp']))
if a.action=='test':
 code='USING: tools.test math compiler threads io alien.c-types alien.syntax ; { "math" "math.bignums" "compiler.tests" "threads" "io.files" "alien" } [ test ] each'
 sys.exit(subprocess.call(ssh+['cd /usr/local/factor; '+shlex.join(['./factor-cpp','-i=/usr/local/factor/factor-cpp.image','-no-user-init','-no-monitors','-e='+code])]))
