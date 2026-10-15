#!/usr/bin/env python3
import os
"""Download pinned official riscv64 BSD releases; keep assets outside the repository."""
import argparse, pathlib, urllib.request, concurrent.futures, gzip, lzma, shutil, subprocess, hashlib, re
FREE='https://download.freebsd.org/releases/VM-IMAGES/14.5-RELEASE/riscv64/Latest/'
NET='https://cdn.netbsd.org/pub/NetBSD/NetBSD-11.0/riscv-riscv64/binary/'
OPEN='https://cdn.openbsd.org/pub/OpenBSD/7.9/riscv64/'
FILES={
'freebsd.qcow2.xz':(FREE,'FreeBSD-14.5-RELEASE-riscv-riscv64-ufs.qcow2.xz','CHECKSUM.SHA256'),
'netbsd.img.gz':(NET+'gzimg/','riscv64.img.gz','SHA512'),
'netbsd-kernel.gz':(NET+'kernel/','netbsd-GENERIC64.gz','SHA512'),
'install79.img':(OPEN,'install79.img','SHA256'),
}
a=argparse.ArgumentParser(description=__doc__);a.add_argument('--assets',type=pathlib.Path,default=pathlib.Path(os.path.join(os.environ.get('FACTOR_QEMU_MATRIX_DIR','/home/sheeple/factor/work/qemu-matrix'),'riscv-bsd')));p=a.parse_args().assets;p.mkdir(parents=True,exist_ok=True)
def fetch(item):
 name,(base,remote,checks)=item
 target=p/name
 if not target.exists():
  temp=p/(name+'.partial');urllib.request.urlretrieve(base+remote,temp);temp.rename(target)
 sums=urllib.request.urlopen(base+checks).read().decode();(p/(name+'.checksums')).write_text(sums)
 line=next(l for l in sums.splitlines() if '('+remote+')' in l)
 expected=line.split('=')[-1].strip();actual=hashlib.new('sha512' if checks=='SHA512' else 'sha256',target.read_bytes()).hexdigest()
 if actual!=expected:raise RuntimeError('Checksum mismatch: '+name)
 print(name,'verified',flush=True)
with concurrent.futures.ThreadPoolExecutor(4) as e:list(e.map(fetch,FILES.items()))
for source,target,opener in [('freebsd.qcow2.xz','freebsd.qcow2',lzma.open),('netbsd.img.gz','netbsd.img',gzip.open),('netbsd-kernel.gz','netbsd-kernel',gzip.open)]:
 if not (p/target).exists():
  with opener(p/source,'rb') as i,open(p/target,'wb') as o:shutil.copyfileobj(i,o)
if not (p/'openbsd.qcow2').exists():subprocess.run(['qemu-img','create','-f','qcow2',str(p/'openbsd.qcow2'),'20G'],check=True)
print('Boot images ready. NetBSD disk can be enlarged with qemu-img resize -f raw netbsd.img 20G before its first boot.')
