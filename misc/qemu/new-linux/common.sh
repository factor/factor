#!/usr/bin/env bash
# Shared setup for rootfs-based guests; machine and boot options stay in launchers.
prepare_guest_disk() {
 local assets=$1 root=$1/root hostname=$2 root_device=$3 dhcp_client=$4
 [[ ! -f "$assets/guest.raw" ]] || return 0
 sudo chroot "$root" apt-get update
 sudo chroot "$root" apt-get -o DPkg::Lock::Timeout=600 install -y systemd-sysv ifupdown "$dhcp_client" iproute2
 sudo mkdir -p "$root/root/.ssh" "$root/etc/network/interfaces.d"
 sudo cp "${FACTOR_QEMU_PUBLIC_KEY:-/home/sheeple/factor/work/qemu-matrix/linux/id_ed25519.pub}" "$root/root/.ssh/authorized_keys"
 sudo chmod 700 "$root/root/.ssh"
 sudo chmod 600 "$root/root/.ssh/authorized_keys"
 printf 'PermitRootLogin prohibit-password\n' | sudo tee "$root/etc/ssh/sshd_config.d/factor-infra.conf" >/dev/null
 printf 'auto lo\niface lo inet loopback\nauto eth0\niface eth0 inet dhcp\n' | sudo tee "$root/etc/network/interfaces" >/dev/null
 printf '%s / ext4 defaults 0 1\n' "$root_device" | sudo tee "$root/etc/fstab" >/dev/null
 printf '%s\n' "$hostname" | sudo tee "$root/etc/hostname" >/dev/null
 printf '127.0.0.1 localhost\n::1 localhost ip6-localhost ip6-loopback\n127.0.1.1 %s\n' "$hostname" | sudo tee "$root/etc/hosts" >/dev/null
 sudo chroot "$root" passwd -d root
 for path in dev/pts proc sys dev; do
  if mountpoint -q "$root/$path"; then sudo umount "$root/$path"; fi
 done
 truncate -s 12G "$assets/guest.raw.part"
 sudo mkfs.ext4 -q -F -d "$root" "$assets/guest.raw.part"
 sudo chown "$(id -u):$(id -g)" "$assets/guest.raw.part"
 mv "$assets/guest.raw.part" "$assets/guest.raw"
}
