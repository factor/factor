
IN: unix.linux.sockios

! Imported from linux-headers-2.6.15-28-686 on Ubuntu 6.06

! Socket configuration controls

: SIOCGIFNAME	     HEX: 8910 ;		! get iface name
: SIOCSIFLINK	     HEX: 8911 ;		! set iface channel
: SIOCGIFCONF	     HEX: 8912 ;		! get iface list
: SIOCGIFFLAGS	     HEX: 8913 ;		! get flags
: SIOCSIFFLAGS	     HEX: 8914 ;		! set flags
: SIOCGIFADDR	     HEX: 8915 ;		! get PA address
: SIOCSIFADDR	     HEX: 8916 ;		! set PA address
: SIOCGIFDSTADDR     HEX: 8917 ;		! get remote PA address
: SIOCSIFDSTADDR     HEX: 8918 ;		! set remote PA address
: SIOCGIFBRDADDR     HEX: 8919 ;		! get broadcast PA address
: SIOCSIFBRDADDR     HEX: 891a ;		! set broadcast PA address
: SIOCGIFNETMASK     HEX: 891b ;		! get network PA mask
: SIOCSIFNETMASK     HEX: 891c ;		! set network PA mask
: SIOCGIFMETRIC	     HEX: 891d ;		! get metric
: SIOCSIFMETRIC	     HEX: 891e ;		! set metric
: SIOCGIFMEM	     HEX: 891f ;		! get memory address (BSD)
: SIOCSIFMEM	     HEX: 8920 ;		! set memory address (BSD)
: SIOCGIFMTU	     HEX: 8921 ;		! get MTU size
: SIOCSIFMTU	     HEX: 8922 ;		! set MTU size
: SIOCSIFNAME	     HEX: 8923 ;		! set interface name
: SIOCSIFHWADDR	     HEX: 8924 ;		! set hardware address
: SIOCGIFENCAP	     HEX: 8925 ;		! get/set encapsulations
: SIOCSIFENCAP	     HEX: 8926 ;
: SIOCGIFHWADDR	     HEX: 8927 ;		! Get hardware address
: SIOCGIFSLAVE	     HEX: 8929 ;		! Driver slaving support
: SIOCSIFSLAVE	     HEX: 8930 ;
: SIOCADDMULTI	     HEX: 8931 ;		! Multicast address lists
: SIOCDELMULTI	     HEX: 8932 ;
: SIOCGIFINDEX	     HEX: 8933 ;		! name -> if_index mapping
: SIOGIFINDEX	     SIOCGIFINDEX ;	        ! misprint compatibility :-)
: SIOCSIFPFLAGS	     HEX: 8934 ;		! set/get extended flags set
: SIOCGIFPFLAGS	     HEX: 8935 ;
: SIOCDIFADDR	     HEX: 8936 ;		! delete PA address
: SIOCSIFHWBROADCAST HEX: 8937 ;		! set hardware broadcast addr
: SIOCGIFCOUNT	     HEX: 8938 ;		! get number of devices

: SIOCGIFBR	     HEX: 8940 ;		! Bridging support
: SIOCSIFBR	     HEX: 8941 ;		! Set bridging options

: SIOCGIFTXQLEN	     HEX: 8942 ;		! Get the tx queue length
: SIOCSIFTXQLEN	     HEX: 8943 ;		! Set the tx queue length

: SIOCGIFDIVERT	     HEX: 8944 ;		! Frame diversion support
: SIOCSIFDIVERT	     HEX: 8945 ;		! Set frame diversion options

: SIOCETHTOOL	     HEX: 8946 ;		! Ethtool interface

: SIOCGMIIPHY	     HEX: 8947 ;		! Get address of MII PHY in use
: SIOCGMIIREG	     HEX: 8948 ;		! Read MII PHY register.
: SIOCSMIIREG	     HEX: 8949 ;		! Write MII PHY register.

: SIOCWANDEV	     HEX: 894A ;		! get/set netdev parameters
