USING: alien.c-types alien.syntax classes.struct unix.types unix.ffi.bsd ;
IN: unix.ffi

CONSTANT: AF_INET 2
ALIAS: PF_INET AF_INET
CONSTANT: AF_INET6 28
ALIAS: PF_INET6 AF_INET6

CONSTANT: FD_SETSIZE 1024

STRUCT: sockaddr
    { sa_len uchar }
    { sa_family __uint8_t }
    { sa_data char[14] } ;

STRUCT: addrinfo
    { flags int }
    { family int }
    { socktype int }
    { protocol int }
    { addrlen socklen_t }
    { canonname c-string }
    { addr void* }
    { next addrinfo* } ;

STRUCT: dirent
    { d_fileno ino_t }
    { d_off off_t }
    { d_reclen __uint16_t }
    { d_type uint8_t }
    { d_pad0 uint8_t }
    { d_namlen __uint16_t }
    { d_pad1 __uint16_t }
    { d_name char[256] } ;

CONSTANT: SOL_SOCKET 0xffff
CONSTANT: SO_DEBUG 0x1
CONSTANT: SO_ACCEPTCONN 0x2
CONSTANT: SO_REUSEADDR 0x4
CONSTANT: SO_KEEPALIVE 0x8
CONSTANT: SO_DONTROUTE 0x10
CONSTANT: SO_BROADCAST 0x20
CONSTANT: SO_OOBINLINE 0x100
CONSTANT: SO_SNDBUF 0x1001
CONSTANT: SO_RCVBUF 0x1002
CONSTANT: SO_SNDLOWAT 0x1003
CONSTANT: SO_RCVLOWAT 0x1004
CONSTANT: SO_SNDTIMEO 0x1005
CONSTANT: SO_RCVTIMEO 0x1006
CONSTANT: SO_ERROR 0x1007
CONSTANT: SO_TYPE 0x1008

