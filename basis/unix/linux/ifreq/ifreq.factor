
USING: kernel alien alien.c-types
       io.sockets
       unix
       unix.linux.sockios
       unix.linux.if ;

IN: unix.linux.ifreq

: set-if-addr ( name addr -- )
  "struct-ifreq" <c-object>
  rot  ascii string>alien       over set-struct-ifreq-ifr-ifrn
  swap 0 <inet4> make-sockaddr  over set-struct-ifreq-ifr-ifru

  AF_INET SOCK_DGRAM 0 socket SIOCSIFADDR rot ioctl drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: set-if-flags ( name flags -- )
  "struct-ifreq" <c-object>
  rot  ascii string>alien over set-struct-ifreq-ifr-ifrn
  swap <short>		 over set-struct-ifreq-ifr-ifru

  AF_INET SOCK_DGRAM 0 socket SIOCSIFFLAGS rot ioctl drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: set-if-dst-addr ( name addr -- )
  "struct-ifreq" <c-object>
  rot  ascii string>alien       over set-struct-ifreq-ifr-ifrn
  swap 0 <inet4> make-sockaddr  over set-struct-ifreq-ifr-ifru

  AF_INET SOCK_DGRAM 0 socket SIOCSIFDSTADDR rot ioctl drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: set-if-brd-addr ( name addr -- )
  "struct-ifreq" <c-object>
  rot  ascii string>alien       over set-struct-ifreq-ifr-ifrn
  swap 0 <inet4> make-sockaddr  over set-struct-ifreq-ifr-ifru

  AF_INET SOCK_DGRAM 0 socket SIOCSIFBRDADDR rot ioctl drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: set-if-netmask ( name addr -- )
  "struct-ifreq" <c-object>
  rot  ascii string>alien       over set-struct-ifreq-ifr-ifrn
  swap 0 <inet4> make-sockaddr  over set-struct-ifreq-ifr-ifru

  AF_INET SOCK_DGRAM 0 socket SIOCSIFNETMASK rot ioctl drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: set-if-metric ( name metric -- )
  "struct-ifreq" <c-object>
  rot ascii string>alien over set-struct-ifreq-ifr-ifrn
  swap <int>		over set-struct-ifreq-ifr-ifru

  AF_INET SOCK_DGRAM 0 socket SIOCSIFMETRIC rot ioctl drop ;