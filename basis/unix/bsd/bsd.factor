! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax classes.struct combinators
system unix.types vocabs.loader ;
IN: unix

CONSTANT: MAXPATHLEN 1024

CONSTANT: O_RDONLY   HEX: 0000
CONSTANT: O_WRONLY   HEX: 0001
CONSTANT: O_RDWR     HEX: 0002
CONSTANT: O_NONBLOCK HEX: 0004
CONSTANT: O_APPEND   HEX: 0008
CONSTANT: O_CREAT    HEX: 0200
CONSTANT: O_TRUNC    HEX: 0400
CONSTANT: O_EXCL     HEX: 0800
CONSTANT: O_NOCTTY   HEX: 20000
ALIAS: O_NDELAY O_NONBLOCK

CONSTANT: SOL_SOCKET HEX: ffff
CONSTANT: SO_REUSEADDR HEX: 4
CONSTANT: SO_OOBINLINE HEX: 100
CONSTANT: SO_SNDTIMEO HEX: 1005
CONSTANT: SO_RCVTIMEO HEX: 1006

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
    { pw_name char* }
    { pw_passwd char* }
    { pw_uid uid_t }
    { pw_gid gid_t }
    { pw_change time_t }
    { pw_class char* }
    { pw_gecos char* }
    { pw_dir char* }
    { pw_shell char* }
    { pw_expire time_t }
    { pw_fields int } ;

CONSTANT: max-un-path 104

CONSTANT: SOCK_STREAM 1
CONSTANT: SOCK_DGRAM 2

CONSTANT: AF_UNSPEC 0
CONSTANT: AF_UNIX 1
CONSTANT: AF_INET 2
CONSTANT: AF_INET6 30

ALIAS: PF_UNSPEC AF_UNSPEC
ALIAS: PF_UNIX AF_UNIX
ALIAS: PF_INET AF_INET
ALIAS: PF_INET6 AF_INET6

CONSTANT: IPPROTO_TCP 6
CONSTANT: IPPROTO_UDP 17

CONSTANT: AI_PASSIVE 1

CONSTANT: SEEK_SET 0
CONSTANT: SEEK_CUR 1
CONSTANT: SEEK_END 2

os {
    { macosx  [ "unix.bsd.macosx"  require ] }
    { freebsd [ "unix.bsd.freebsd" require ] }
    { openbsd [ "unix.bsd.openbsd" require ] }
    { netbsd  [ "unix.bsd.netbsd"  require ] }
} case
