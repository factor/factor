! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax combinators system vocabs.loader ;
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

C-STRUCT: sockaddr-in
    { "uchar" "len" }
    { "uchar" "family" }
    { "ushort" "port" }
    { "in_addr_t" "addr" }
    { "longlong" "unused" } ;

C-STRUCT: sockaddr-in6
    { "uchar" "len" }
    { "uchar" "family" }
    { "ushort" "port" }
    { "uint" "flowinfo" }
    { { "uchar" 16 } "addr" }
    { "uint" "scopeid" } ;

C-STRUCT: sockaddr-un
    { "uchar" "len" }
    { "uchar" "family" }
    { { "char" 104 } "path" } ;

C-STRUCT: passwd
    { "char*"  "pw_name" }
    { "char*"  "pw_passwd" }
    { "uid_t"  "pw_uid" }
    { "gid_t"  "pw_gid" }
    { "time_t" "pw_change" }
    { "char*"  "pw_class" }
    { "char*"  "pw_gecos" }
    { "char*"  "pw_dir" }
    { "char*"  "pw_shell" }
    { "time_t" "pw_expire" }
    { "int"    "pw_fields" } ;

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
