
USING: namespaces unix.linux.if unix.linux.ifreq unix.linux.route ;

IN: raptor

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Networking
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: configure-lo ( -- )
  "lo" "127.0.0.1"      set-if-addr
  "lo" { IFF_UP } flags set-if-flags ;

: configure-eth1 ( -- )
  "eth1" "192.168.1.10"                 set-if-addr
  "eth1" { IFF_UP IFF_MULTICAST } flags set-if-flags ;

: configure-route ( -- )
  "0.0.0.0" "192.168.1.1" "0.0.0.0" { RTF_UP RTF_GATEWAY } flags route ;

[
  configure-lo
  configure-eth1
  configure-route
] networking-hook set-global

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

[

  ! rcS.d

  "mountvirtfs"                     start-service
  "hostname.sh"			    start-service
  "keymap.sh"			    start-service
  "linux-restricted-modules-common" start-service
  "udev"                            start-service
  "mountdevsubfs" 		    start-service
  "module-init-tools" 		    start-service
  "procps.sh" 			    start-service
  "checkroot.sh"		    start-service
  "mtab"			    start-service
  "checkfs.sh" 			    start-service
  "mountall.sh"			    start-service

 				    start-networking
!   "loopback" start-service
!   "networking" start-service

  "hwclock.sh"			    start-service
  "displayconfig-hwprobe.py"	    start-service
  "screen"			    start-service
  "x11-common"			    start-service
  "bootmisc.sh"			    start-service
  "urandom"			    start-service

  ! rc2.d

  "vbesave"	                    start-service
  "acpid"			    start-service
  "powernowd.early"		    start-service
  "sysklogd"			    start-service
  "klogd"			    start-service
  "dbus"			    start-service
  "apmd"			    start-service
  "hotkey-setup"		    start-service
  "laptop-mode"			    start-service
  "makedev"			    start-service
  "nvidia-kernel"		    start-service
  "postfix"			    start-service
  "powernowd"			    start-service
  "ntp-server"			    start-service
  "binfmt-support"		    start-service
  "acpi-support"		    start-service
  "rc.local"			    start-service
  "rmnologin"			    start-service

  				    schedule-cron-jobs
  				    start-listeners
				    start-gettys
				    
] boot-hook set-global

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

[
  "acpi-support" 		    stop-service
  "apmd" 			    stop-service
  "dbus" 			    stop-service
  "hotkey-setup" 		    stop-service
  "laptop-mode" 		    stop-service
  "makedev" 			    stop-service
  "nvidia-kernel" 		    stop-service
  "powernowd" 			    stop-service
  "acpid" 			    stop-service
  "hwclock.sh" 			    stop-service
  "alsa-utils" 			    stop-service
  "klogd" 			    stop-service
  "binfmt-support" 		    stop-service
  "sysklogd"                        stop-service
  "linux-restricted-modules-common" stop-service
  "sendsigs" 			    stop-service
  "urandom" 			    stop-service
  "umountnfs.sh" 		    stop-service
  "networking" 			    stop-service
  "umountfs" 			    stop-service
  "umountroot" 			    stop-service
  "reboot" 			    stop-service
] reboot-hook set-global

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

[
  "acpi-support" 		    stop-service
  "apmd" 			    stop-service
  "dbus" 			    stop-service
  "hotkey-setup" 		    stop-service
  "laptop-mode" 		    stop-service
  "makedev" 			    stop-service
  "nvidia-kernel" 		    stop-service
  "postfix" 			    stop-service
  "powernowd" 			    stop-service
  "acpid" 			    stop-service
  "hwclock.sh" 			    stop-service
  "alsa-utils" 			    stop-service
  "klogd" 			    stop-service
  "binfmt-support" 		    stop-service
  "sysklogd" 			    stop-service
  "linux-restricted-modules-common" stop-service
  "sendsigs" 			    stop-service
  "urandom" 			    stop-service
  "umountnfs.sh" 		    stop-service
  "umountfs" 			    stop-service
  "umountroot" 			    stop-service
  "halt" 			    stop-service
] shutdown-hook set-global