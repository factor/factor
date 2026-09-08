import hashlib, json, pathlib, platform, subprocess
root=pathlib.Path(__file__).resolve().parent.parent
out=root/'validation'
def command(*args):
 return subprocess.check_output(args,cwd=root,text=True).strip()
def sha256(path):
 h=hashlib.sha256()
 with path.open('rb') as f:
  for b in iter(lambda:f.read(1024*1024),b''): h.update(b)
 return h.hexdigest()
result={
 'source_commit':command('git','rev-parse','HEAD'),
 'tracked_changes':command('git','status','--short','--untracked-files=no'),
 'platform':platform.platform(),
 'os_release':pathlib.Path('/etc/os-release').read_text(),
 'compiler':command('g++','--version').splitlines()[0],
 'libc':command('ldd','--version').splitlines()[0],
 'artifacts':{p.name:sha256(p) for p in [root/'factor',root/'factor.image',root/'loaded.image',root/'boot.unix-x86.64.image']},
 'test_packages':{p.name:sha256(p) for p in sorted((out/'packages').glob('*.deb'))},
 'pcre_source_sha256':sha256(out/'packages/pcre-8.45.tar.bz2'),
 'test_services':{'postgresql':{'host':'127.0.0.1','port':64578},'redis':{'host':'127.0.0.1','port':64580},'xvfb':{'display':':98'}},
}
(out/'provenance.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result,indent=2))
