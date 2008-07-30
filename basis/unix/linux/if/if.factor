
USING: alien.syntax ;

IN: unix.linux.if

: IFNAMSIZ    16 ;
: IF_NAMESIZE 16 ;
: IFHWADDRLEN 6 ;

! Standard interface flags (netdevice->flags)

: IFF_UP          HEX: 1 ;		! interface is up
: IFF_BROADCAST   HEX: 2 ;		! broadcast address valid
: IFF_DEBUG 	  HEX: 4 ;		! turn on debugging
: IFF_LOOPBACK 	  HEX: 8 ;		! is a loopback net
: IFF_POINTOPOINT HEX: 10 ;		! interface is has p-p link
: IFF_NOTRAILERS  HEX: 20 ;		! avoid use of trailers
: IFF_RUNNING 	  HEX: 40 ;		! interface running and carrier ok
: IFF_NOARP 	  HEX: 80 ;		! no ARP protocol
: IFF_PROMISC 	  HEX: 100 ;		! receive all packets
: IFF_ALLMULTI 	  HEX: 200 ;		! receive all multicast packets

: IFF_MASTER 	  HEX: 400 ;		! master of a load balancer
: IFF_SLAVE 	  HEX: 800 ;		! slave of a load balancer

: IFF_MULTICAST   HEX: 1000 ;		! Supports multicast

! #define IFF_VOLATILE
! (IFF_LOOPBACK|IFF_POINTOPOINT|IFF_BROADCAST|IFF_MASTER|IFF_SLAVE|IFF_RUNNING)

: IFF_PORTSEL     HEX: 2000 ;           ! can set media type
: IFF_AUTOMEDIA   HEX: 4000 ;		! auto media select active
: IFF_DYNAMIC 	  HEX: 8000 ;		! dialup device with changing addresses

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

C-STRUCT: struct-ifmap
  { "ulong" "mem-start" }
  { "ulong" "mem-end" }
  { "ushort" "base-addr" }
  { "uchar" "irq" }
  { "uchar" "dma" }
  { "uchar" "port" } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Hmm... the generic sockaddr type isn't defined anywhere.
! Put it here for now.

TYPEDEF: ushort sa_family_t

C-STRUCT: struct-sockaddr
  { "sa_family_t" "sa_family" }
  { { "char" 14 } "sa_data" } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! C-UNION: union-ifr-ifrn { "char" IFNAMSIZ } ;

C-UNION: union-ifr-ifrn { "char" 16 } ;

C-UNION: union-ifr-ifru
 "struct-sockaddr"
!   "sockaddr"
  "short"
  "int"
  "struct-ifmap"
!   { "char" IFNAMSIZ }
  { "char" 16 }
  "caddr_t" ;

C-STRUCT: struct-ifreq
  { "union-ifr-ifrn" "ifr-ifrn" }
  { "union-ifr-ifru" "ifr-ifru" } ;

: ifr-name      ( struct-ifreq -- value ) struct-ifreq-ifr-ifrn ;

: ifr-hwaddr 	( struct-ifreq -- value ) struct-ifreq-ifr-ifru ;
: ifr-addr 	( struct-ifreq -- value ) struct-ifreq-ifr-ifru ;
: ifr-dstaddr 	( struct-ifreq -- value ) struct-ifreq-ifr-ifru ;
: ifr-broadaddr ( struct-ifreq -- value ) struct-ifreq-ifr-ifru ;
: ifr-netmask 	( struct-ifreq -- value ) struct-ifreq-ifr-ifru ;
: ifr-flags 	( struct-ifreq -- value ) struct-ifreq-ifr-ifru ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

C-UNION: union-ifc-ifcu "caddr_t" "struct-ifreq*" ;

C-STRUCT: struct-ifconf
  { "int" "ifc-len" }
  { "union-ifc-ifcu" "ifc-ifcu" } ;

: ifc-len ( struct-ifconf -- value ) struct-ifconf-ifc-len ;

: ifc-buf ( struct-ifconf -- value ) struct-ifconf-ifc-ifcu ;
: ifc-req ( struct-ifconf -- value ) struct-ifconf-ifc-ifcu ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!