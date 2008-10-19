! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax combinators system vocabs.loader ;
IN: unix

: MAXPATHLEN 1024 ; inline

: O_RDONLY   HEX: 0000 ; inline
: O_WRONLY   HEX: 0001 ; inline
: O_RDWR     HEX: 0002 ; inline
: O_NONBLOCK HEX: 0004 ; inline
: O_APPEND   HEX: 0008 ; inline
: O_CREAT    HEX: 0200 ; inline
: O_TRUNC    HEX: 0400 ; inline
: O_EXCL     HEX: 0800 ; inline
: O_NOCTTY   HEX: 20000 ; inline
: O_NDELAY O_NONBLOCK ; inline

: SOL_SOCKET HEX: ffff ; inline
: SO_REUSEADDR HEX: 4 ; inline
: SO_OOBINLINE HEX: 100 ; inline
: SO_SNDTIMEO HEX: 1005 ; inline
: SO_RCVTIMEO HEX: 1006 ; inline

: F_SETFD 2 ; inline
: F_SETFL 4 ; inline
: FD_CLOEXEC 1 ; inline

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

: max-un-path 104 ; inline

: SOCK_STREAM 1 ; inline
: SOCK_DGRAM 2 ; inline

: AF_UNSPEC 0 ; inline
: AF_UNIX 1 ; inline
: AF_INET 2 ; inline
: AF_INET6 30 ; inline

: PF_UNSPEC AF_UNSPEC ; inline
: PF_UNIX AF_UNIX ; inline
: PF_INET AF_INET ; inline
: PF_INET6 AF_INET6 ; inline

: IPPROTO_TCP 6 ; inline
: IPPROTO_UDP 17 ; inline

: AI_PASSIVE 1 ; inline

: SEEK_SET 0 ; inline
: SEEK_CUR 1 ; inline
: SEEK_END 2 ; inline

os {
    { macosx  [ "unix.bsd.macosx"  require ] }
    { freebsd [ "unix.bsd.freebsd" require ] }
    { openbsd [ "unix.bsd.openbsd" require ] }
    { netbsd  [ "unix.bsd.netbsd"  require ] }
} case
