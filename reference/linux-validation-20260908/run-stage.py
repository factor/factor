import json, os, pathlib, signal, subprocess, sys, time
root=pathlib.Path(__file__).resolve().parent.parent
out=root/'validation'
stage=sys.argv[1]
image='boot.unix-x86.64.image' if stage=='bootstrap' else ('factor.image' if stage=='load-all' else 'loaded.image')
cmd=[str(root/'factor'),'-resource-path='+str(root),'-no-user-init','-no-monitors','-i='+str(root/image)]
if stage=='bootstrap': cmd+=['-output-image='+str(root/'factor.image')]
else: cmd+=[str(out/(stage+'.factor'))]
env=os.environ.copy()
env['LD_LIBRARY_PATH']=str(out/'libraries/usr/lib/x86_64-linux-gnu')+':'+str(out/'libraries/usr/lib/x86_64-linux-gnu/blas')+':'+str(out/'libraries/usr/lib')+':'+str(out/'libraries/lib')
env['DISPLAY']=':98'
start=time.monotonic()
with (out/(stage+'.log')).open('wb') as log:
 p=subprocess.Popen(cmd,cwd=root,env=env,stdout=log,stderr=subprocess.STDOUT,start_new_session=True)
 (out/(stage+'.pid')).write_text(str(p.pid))
 try: status=p.wait(timeout=7200)
 except subprocess.TimeoutExpired:
  os.killpg(p.pid,signal.SIGTERM)
  try: p.wait(timeout=10)
  except subprocess.TimeoutExpired: os.killpg(p.pid,signal.SIGKILL);p.wait()
  status=124
result=dict(command=cmd,status=status,seconds=time.monotonic()-start)
(out/(stage+'.json')).write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result),flush=True)
sys.exit(status)
