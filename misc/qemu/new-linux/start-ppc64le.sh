#!/usr/bin/env bash
set -euo pipefail
assets=${FACTOR_QEMU_ASSETS:-/home/sheeple/factor/work/qemu-matrix/new-linux/ppc64le}
port=${FACTOR_QEMU_SSH_PORT:-22901}
mkdir -p "$assets"
if [[ ! -f "$assets/base.qcow2" ]]; then
 curl -fL https://cloud.debian.org/images/cloud/trixie/latest/debian-13-generic-ppc64el.qcow2 -o "$assets/base.qcow2.part"
 mv "$assets/base.qcow2.part" "$assets/base.qcow2"
fi
if [[ -f "$assets/guest.pid" ]] && kill -0 "$(cat "$assets/guest.pid")" 2>/dev/null; then
 echo "Guest already running: $(cat "$assets/guest.pid")"; exit 0
fi
if [[ ! -f "$assets/guest.qcow2" ]]; then
 qemu-img create -f qcow2 -F qcow2 -b "$assets/base.qcow2" "$assets/guest.qcow2" 20G
fi
key=${FACTOR_QEMU_PUBLIC_KEY:-/home/sheeple/factor/work/qemu-matrix/linux/id_ed25519.pub}
cat > "$assets/user-data" <<CONFIG
#cloud-config
users:
  - name: factor
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - $(cat "$key")
package_update: true
packages: [gcc, g++, make, bash, ca-certificates, libssl-dev, libcapstone-dev]
runcmd:
  - [sh, -c, 'touch /home/factor/infrastructure-ready']
CONFIG
printf 'instance-id: factor-ppc64le\nlocal-hostname: factor-ppc64le\n' > "$assets/meta-data"
cloud-localds "$assets/seed.iso" "$assets/user-data" "$assets/meta-data"
qemu-system-ppc64 -machine pseries -cpu power9 -m 2048 -smp 2 -accel tcg -display none -serial file:"$assets/console.log" -drive file="$assets/guest.qcow2",format=qcow2,if=virtio -drive file="$assets/seed.iso",format=raw,if=virtio -device virtio-net-pci,netdev=net0 -netdev user,id=net0,hostfwd=tcp:127.0.0.1:"$port"-:22 -daemonize -pidfile "$assets/guest.pid"
echo "PPC64LE guest started; SSH factor@127.0.0.1 port $port"
