#!/usr/bin/env python3
"""Cross-build the C++ RISC-V BSD VMs against headers/libraries from real guests.

Requires clang-21, lld-21, GNU make, and a native sysroot. BSD release images
include the C++ compiler; host cross-building avoids costly emulated compilation.
The source tree's ordinary Makefile builds both the VM and its native FFI oracle.
"""
import argparse, pathlib, subprocess, os, shlex, fcntl, json
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('system',choices=['freebsd','netbsd','openbsd'])
p.add_argument('--assets',type=pathlib.Path,default=pathlib.Path(os.path.join(os.environ.get('FACTOR_QEMU_MATRIX_DIR','/home/sheeple/factor/work/qemu-matrix'),'riscv-bsd')))
p.add_argument('--sysroot',type=pathlib.Path)
p.add_argument('--source',type=pathlib.Path,default=pathlib.Path(__file__).resolve().parents[2])
p.add_argument('--source-revision',help='Exact revision for a frozen archive; overrides ancestor Git labels')
p.add_argument('--unit-source',type=pathlib.Path,help='Separately versioned native relocation fixture')
p.add_argument('--jobs',type=int,default=8)
a=p.parse_args();a.assets=a.assets.resolve();root=(a.sysroot or a.assets/f'{a.system}-sysroot').resolve();a.assets.mkdir(parents=True,exist_ok=True)
target={'freebsd':'riscv64-unknown-freebsd14.5','netbsd':'riscv64-unknown-netbsd11.0','openbsd':'riscv64-unknown-openbsd7.9'}[a.system]
base=[f'--target={target}',f'--sysroot={root}','--ld-path=/usr/bin/ld.lld-21']
cpp=['-nostdinc++','-isystem',str(root/'usr/include'/('g++' if a.system=='netbsd' else 'c++/v1'))]
if a.system=='netbsd':
 base+=['-D__WCHAR_MIN__=-2147483648','-D__WCHAR_MAX__=2147483647','-U__WINT_TYPE__','-D__WINT_TYPE__=int','-U__WINT_UNSIGNED__','-D__WINT_MIN__=-2147483648','-U__WINT_MAX__','-D__WINT_MAX__=2147483647','-D__SIG_ATOMIC_TYPE__=int'];cpp+=['-stdlib=libstdc++']
env=os.environ.copy();env['CC']=shlex.join(['/usr/bin/clang-21']+base);env['CXX']=shlex.join(['/usr/bin/clang++-21']+base+cpp)
cmd=['/usr/bin/make',f'-j{a.jobs}',f'CONFIG=vm/Config.{a.system}.riscv.64',f'BUILD_DIR={a.assets}/cross-{a.system}-build',f'EXECUTABLE={a.assets}/{a.system}-factor',f'FFI_TEST_LIBRARY={a.assets}/{a.system}-libfactor-ffi-test.so','factor-executable','factor-ffi-test']
if a.source_revision:
 cmd.append('GIT_LABEL=recovery-'+a.source_revision)
if a.system=='openbsd':
 cmd+=['RETGUARD_FLAGS=','LDFLAGS=-pie']
 # OpenBSD native ld scans versioned libraries; upstream LLD needs .so links.
 groups={}
 for lib in (root/'usr/lib').glob('*.so.*'):
  stem,version=lib.name.split('.so.',1)
  try:key=tuple(int(x) for x in version.split('.'))
  except ValueError:continue
  if stem not in groups or key>groups[stem][0]:groups[stem]=(key,lib)
 for stem,(_,lib) in groups.items():
  link=lib.parent/(stem+'.so')
  if not link.exists():link.symlink_to(lib.name)
with open(a.assets/'cross-build.lock','w') as lock:
 fcntl.flock(lock,fcntl.LOCK_EX)
 manifest=a.assets/f'{a.system}-cross-toolchain.json'
 profile=json.dumps({'cc':env['CC'],'cxx':env['CXX'],'config':(a.source/f'vm/Config.{a.system}.riscv.64').read_text(),'source_revision':a.source_revision,'link_options':cmd[-2:] if a.system=='openbsd' else []},sort_keys=True)
 if not manifest.exists() or manifest.read_text()!=profile:cmd+=['--always-make']
 for name in ["factor","libfactor-ffi-test.so"]:
  output=a.assets/f"{a.system}-{name}"
  if output.exists():output.unlink()
 with open(a.assets/f'{a.system}-cross-build.log','w') as log:
  subprocess.run(cmd,cwd=a.source,env=env,stdout=log,stderr=subprocess.STDOUT,check=True)
 manifest.write_text(profile)

subprocess.run(['/usr/bin/clang++-21']+base+cpp+['-std=c++17','-O2','-march=rv64gc','-mabi=lp64d',str(a.unit_source or a.source/'vm/tests/riscv.cpp'),'-o',str(a.assets/f'{a.system}-riscv-tests')]+(['-pie','-Wl,-z,wxneeded'] if a.system=='openbsd' else []),check=True)
print(a.system,'C++ VM, FFI oracle, and relocation tests built')
