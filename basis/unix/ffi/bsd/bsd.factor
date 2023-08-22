! Copyright (C) 2005, 2006 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax classes.struct combinators
system unix.types vocabs.loader ;
IN: unix.ffi

CONSTANT: MAXPATHLEN 1024

CONSTANT: O_RDONLY   0x0000
CONSTANT: O_WRONLY   0x0001
CONSTANT: O_RDWR     0x0002
CONSTANT: O_NONBLOCK 0x0004
CONSTANT: O_APPEND   0x0008
CONSTANT: O_CREAT    0x0200
CONSTANT: O_TRUNC    0x0400
CONSTANT: O_EXCL     0x0800
CONSTANT: O_NOCTTY   0x20000
ALIAS: O_NDELAY O_NONBLOCK

CONSTANT: SOL_SOCKET 0xffff
CONSTANT: SO_REUSEADDR 0x4
CONSTANT: SO_OOBINLINE 0x100
CONSTANT: SO_SNDTIMEO 0x1005
CONSTANT: SO_RCVTIMEO 0x1006

CONSTANT: F_SETFD 2
CONSTANT: F_SETFL 4
CONSTANT: FD_CLOEXEC 1

STRUCT: sockaddr-in
    { len uchar }
    { family uchar }
    { port ushort }
    { addr in_addr_t }
    { unused longlong } ;

STRUCT: sockaddr-in6
    { len uchar }
    { family uchar }
    { port ushort }
    { flowinfo uint }
    { addr uchar[16] }
    { scopeid uint } ;

STRUCT: sockaddr-un
    { len uchar }
    { family uchar }
    { path char[104] } ;

STRUCT: passwd
    { pw_name c-string }
    { pw_passwd c-string }
    { pw_uid uid_t }
    { pw_gid gid_t }
    { pw_change time_t }
    { pw_class c-string }
    { pw_gecos c-string }
    { pw_dir c-string }
    { pw_shell c-string }
    { pw_expire time_t }
    { pw_fields int } ;

CONSTANT: max-un-path 104

CONSTANT: SOCK_STREAM 1
CONSTANT: SOCK_DGRAM 2
CONSTANT: SOCK_RAW 3

CONSTANT: AF_UNSPEC 0
CONSTANT: AF_UNIX 1
CONSTANT: AF_INET 2

ALIAS: PF_UNSPEC AF_UNSPEC
ALIAS: PF_UNIX AF_UNIX
ALIAS: PF_INET AF_INET

CONSTANT: IPPROTO_TCP 6
CONSTANT: IPPROTO_UDP 17

CONSTANT: AI_PASSIVE 1

CONSTANT: SEEK_SET 0
CONSTANT: SEEK_CUR 1
CONSTANT: SEEK_END 2


