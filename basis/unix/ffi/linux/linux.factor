! Copyright (C) 2010 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax classes.struct unix.time
unix.types ;
IN: unix.ffi

CONSTANT: MAXPATHLEN 1024

CONSTANT: O_RDONLY   0x0000
CONSTANT: O_WRONLY   0x0001
CONSTANT: O_RDWR     0x0002
CONSTANT: O_CREAT    0x0040
CONSTANT: O_EXCL     0x0080
CONSTANT: O_NOCTTY   0x0100
CONSTANT: O_TRUNC    0x0200
CONSTANT: O_APPEND   0x0400
CONSTANT: O_NONBLOCK 0x0800

ALIAS: O_NDELAY O_NONBLOCK

CONSTANT: SOL_SOCKET 1

CONSTANT: FD_SETSIZE 1024

CONSTANT: SO_DEBUG 1
CONSTANT: SO_REUSEADDR 2
CONSTANT: SO_TYPE 3
CONSTANT: SO_ERROR 4
CONSTANT: SO_DONTROUTE 5
CONSTANT: SO_BROADCAST 6
CONSTANT: SO_SNDBUF 7
CONSTANT: SO_RCVBUF 8
CONSTANT: SO_KEEPALINE 9
CONSTANT: SO_OOBINLINE 10
CONSTANT: SO_SNDTIMEO 0x15
CONSTANT: SO_RCVTIMEO 0x14

CONSTANT: F_SETFD 2
CONSTANT: FD_CLOEXEC 1

CONSTANT: F_SETFL 4

STRUCT: addrinfo
    { flags int }
    { family int }
    { socktype int }
    { protocol int }
    { addrlen socklen_t }
    { addr void* }
    { canonname c-string }
    { next addrinfo* } ;

STRUCT: sockaddr-in
    { family ushort }
    { port ushort }
    { addr in_addr_t }
    { unused longlong } ;

STRUCT: sockaddr-in6
    { family ushort }
    { port ushort }
    { flowinfo uint }
    { addr uchar[16] }
    { scopeid uint } ;

CONSTANT: max-un-path 108

STRUCT: sockaddr-un
    { family ushort }
    { path { char max-un-path } } ;

CONSTANT: SOCK_STREAM 1
CONSTANT: SOCK_DGRAM 2
CONSTANT: SOCK_RAW 3

CONSTANT: AF_UNSPEC 0
CONSTANT: AF_UNIX 1
CONSTANT: AF_INET 2
CONSTANT: AF_INET6 10

ALIAS: PF_UNSPEC AF_UNSPEC
ALIAS: PF_UNIX AF_UNIX
ALIAS: PF_INET AF_INET
ALIAS: PF_INET6 AF_INET6

CONSTANT: IPPROTO_TCP 6
CONSTANT: IPPROTO_UDP 17

! Flags only valid in gnu libcs' getaddrinfo
CONSTANT: AI_IDN                        0x0040
CONSTANT: AI_CANONIDN                   0x0080
CONSTANT: AI_IDN_ALLOW_UNASSIGNED       0x0100
CONSTANT: AI_IDN_USE_STD3_ASCII_RULES   0x0200
CONSTANT: AI_NUMERICSERV                0x0400


CONSTANT: SEEK_SET 0
CONSTANT: SEEK_CUR 1
CONSTANT: SEEK_END 2

STRUCT: passwd
    { pw_name c-string }
    { pw_passwd c-string }
    { pw_uid uid_t }
    { pw_gid gid_t }
    { pw_gecos c-string }
    { pw_dir c-string }
    { pw_shell c-string } ;

! dirent64
STRUCT: dirent
    { d_ino ulonglong }
    { d_off longlong }
    { d_reclen ushort }
    { d_type uchar }
    { d_name char[256] } ;

FUNCTION: int open64 ( c-string path, int flags, int prot )
FUNCTION: dirent* readdir64 ( DIR* dirp )
FUNCTION: int readdir64_r ( void* dirp, dirent* entry, dirent** result )

FUNCTION: ssize_t sendfile ( int out_fd, int in_fd, off_t* offset, size_t count )

FUNCTION: int pipe2 ( int* filedes, int flags )

CONSTANT: __UT_LINESIZE 32
CONSTANT: __UT_NAMESIZE 32
CONSTANT: __UT_HOSTSIZE 256

STRUCT: exit_status
    { e_termination short }
    { e_exit short } ;

STRUCT: utmpx
    { ut_type short }
    { ut_pid pid_t }
    { ut_line char[__UT_LINESIZE] }
    { ut_id char[4] }
    { ut_user char[__UT_NAMESIZE] }
    { ut_host char[__UT_HOSTSIZE] }
    { ut_exit exit_status }
    { ut_session long }
    { ut_tv timeval }
    { ut_addr_v6 int[4] }
    { __unused char[20] } ;
