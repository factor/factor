#!/usr/bin/env python3
"""RISC-V Linux guests for C++ and Zig VM builds and runtime tests.
Assets: FACTOR_QEMU_RISCV_DIR (default work/qemu-matrix/riscv-linux).
"""
import argparse,json,os,pathlib,signal,subprocess
D=pathlib.Path(os.environ.get('FACTOR_QEMU_RISCV_DIR',os.path.join(os.environ.get('FACTOR_QEMU_MATRIX_DIR','/home/sheeple/factor/work/qemu-matrix'),'riscv-linux')))
PORT={'riscv64':22600,'riscv32':22601}
def run(cmd): return subprocess.run(cmd,check=True)
def ssh(a): return ['ssh','-i',str(D/'id_ed25519'),'-p',str(PORT[a]),'-o','StrictHostKeyChecking=no','-o','UserKnownHostsFile=/dev/null','-o','ConnectTimeout=5',f'{"factor" if a=="riscv64" else "root"}@127.0.0.1']
def guest_pid(a):
    try:
        pid=int((D/f"{a}.pid").read_text())
        argv=pathlib.Path(f"/proc/{pid}/cmdline").read_bytes().split(b"\0")
        owned=pathlib.Path(os.fsdecode(argv[0])).name==f"qemu-system-{a}" and any(os.fsencode(str(D)) in arg for arg in argv[1:])
        return pid if owned else None
    except (FileNotFoundError,ProcessLookupError,ValueError,PermissionError):
        return None

def prepare(a):
    if a=='riscv32': return
    key=(D/'id_ed25519.pub').read_text().strip()
    (D/'user-data').write_text('#cloud-config\nusers:\n  - name: factor\n    shell: /bin/bash\n    sudo: ALL=(ALL) NOPASSWD:ALL\n    ssh_authorized_keys:\n      - '+key+'\nssh_pwauth: false\n')
    (D/'meta-data').write_text('instance-id: factor-riscv64\nlocal-hostname: factor-riscv64\n')
    run(['cloud-localds',str(D/'seed.iso'),str(D/'user-data'),str(D/'meta-data')])
    if not (D/'riscv64.qcow2').exists(): run(['qemu-img','create','-f','qcow2','-F','qcow2','-b',str(D/'debian-13-generic-riscv64.qcow2'),str(D/'riscv64.qcow2'),'24G'])
    if not (D/'vars.fd').exists(): run(['cp','/usr/share/qemu-efi-riscv64/RISCV_VIRT_VARS.fd',str(D/'vars.fd')])
def start(a):
    if guest_pid(a) is not None:
        raise SystemExit(f"{a} is already running")
    cmd=[f'qemu-system-{a}','-machine','virt','-m','2048','-smp','2','-display','none','-serial',f'file:{D}/{a}-console.log','-monitor','none','-netdev',f'user,id=net0,hostfwd=tcp:127.0.0.1:{PORT[a]}-:22','-device','virtio-net-device,netdev=net0','-daemonize','-pidfile',str(D/f'{a}.pid')]
    if a=='riscv64': cmd+=['-drive','if=pflash,format=raw,unit=0,readonly=on,file=/usr/share/qemu-efi-riscv64/RISCV_VIRT_CODE.fd','-drive',f'if=pflash,format=raw,unit=1,file={D}/vars.fd','-drive',f'file={D}/riscv64.qcow2,format=qcow2,if=none,id=root','-device','virtio-blk-device,drive=root','-drive',f'file={D}/seed.iso,format=raw,if=none,id=seed','-device','virtio-blk-device,drive=seed']
    else:
        images=D/'buildroot-2026.08/output/images'
        cmd+=['-bios',str(images/'fw_jump.bin'),'-kernel',str(images/'Image'),'-append','rootwait root=/dev/vda rw console=ttyS0','-drive',f'file={images}/rootfs.ext2,format=raw,if=none,id=root','-device','virtio-blk-device,drive=root']
    (D/f'{a}-command.json').write_text(json.dumps(cmd,indent=2)+'\n');run(cmd)
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('action',choices=['prepare','start','ssh','stop','status']);p.add_argument('arch',choices=PORT);p.add_argument('command',nargs=argparse.REMAINDER);args=p.parse_args()
    if args.action=='status':
        running=guest_pid(args.arch) is not None
        print(json.dumps({'arch':args.arch,'running':running,'assets':str(D)}))
        raise SystemExit(0 if running else 1)
    if args.action=='prepare': prepare(args.arch)
    elif args.action=='start': start(args.arch)
    elif args.action=='stop':
        pid=guest_pid(args.arch)
        if pid is None: raise SystemExit(f"{args.arch} is not running")
        os.kill(pid,signal.SIGTERM)
    else: run(ssh(args.arch)+args.command)
