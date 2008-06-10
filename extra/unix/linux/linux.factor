! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: unix
USING: alien.syntax ;

! Linux.

: MAXPATHLEN 1024 ; inline

: O_RDONLY  HEX: 0000 ; inline
: O_WRONLY  HEX: 0001 ; inline
: O_RDWR    HEX: 0002 ; inline
: O_CREAT   HEX: 0040 ; inline
: O_EXCL    HEX: 0080 ; inline
: O_TRUNC   HEX: 0200 ; inline
: O_APPEND  HEX: 0400 ; inline

: SOL_SOCKET 1 ; inline

: FD_SETSIZE 1024 ; inline

: SO_REUSEADDR 2 ; inline
: SO_OOBINLINE 10 ; inline
: SO_SNDTIMEO HEX: 15 ; inline
: SO_RCVTIMEO HEX: 14 ; inline

: F_SETFD 2 ; inline
: FD_CLOEXEC 1 ; inline

: F_SETFL 4 ; inline
: O_NONBLOCK HEX: 800 ; inline

C-STRUCT: addrinfo
    { "int" "flags" }
    { "int" "family" }
    { "int" "socktype" }
    { "int" "protocol" }
    { "socklen_t" "addrlen" }
    { "void*" "addr" }
    { "char*" "canonname" }
    { "addrinfo*" "next" } ;

C-STRUCT: sockaddr-in
    { "ushort" "family" }
    { "ushort" "port" }
    { "in_addr_t" "addr" }
    { "longlong" "unused" } ;

C-STRUCT: sockaddr-in6
    { "ushort" "family" }
    { "ushort" "port" }
    { "uint" "flowinfo" }
    { { "uchar" 16 } "addr" }
    { "uint" "scopeid" } ;

: max-un-path 108 ; inline

C-STRUCT: sockaddr-un
    { "ushort" "family" }
    { { "char" max-un-path } "path" } ;

: SOCK_STREAM 1 ; inline
: SOCK_DGRAM 2 ; inline

: AF_UNSPEC 0 ; inline
: AF_UNIX 1 ; inline
: AF_INET 2 ; inline
: AF_INET6 10 ; inline

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

C-STRUCT: passwd
    { "char*"  "pw_name" }
    { "char*"  "pw_passwd" }
    { "uid_t"  "pw_uid" }
    { "gid_t"  "pw_gid" }
    { "char*"  "pw_gecos" }
    { "char*"  "pw_dir" }
    { "char*"  "pw_shell" } ;

: EPERM 1 ; inline
: ENOENT 2 ; inline
: ESRCH 3 ; inline
: EINTR 4 ; inline
: EIO 5 ; inline
: ENXIO 6 ; inline
: E2BIG 7 ; inline
: ENOEXEC 8 ; inline
: EBADF 9 ; inline
: ECHILD 10 ; inline
: EAGAIN 11 ; inline
: ENOMEM 12 ; inline
: EACCES 13 ; inline
: EFAULT 14 ; inline
: ENOTBLK 15 ; inline
: EBUSY 16 ; inline
: EEXIST 17 ; inline
: EXDEV 18 ; inline
: ENODEV 19 ; inline
: ENOTDIR 20 ; inline
: EISDIR 21 ; inline
: EINVAL 22 ; inline
: ENFILE 23 ; inline
: EMFILE 24 ; inline
: ENOTTY 25 ; inline
: ETXTBSY 26 ; inline
: EFBIG 27 ; inline
: ENOSPC 28 ; inline
: ESPIPE 29 ; inline
: EROFS 30 ; inline
: EMLINK 31 ; inline
: EPIPE 32 ; inline
: EDOM 33 ; inline
: ERANGE 34 ; inline
: EDEADLK 35 ; inline
: ENAMETOOLONG 36 ; inline
: ENOLCK 37 ; inline
: ENOSYS 38 ; inline
: ENOTEMPTY 39 ; inline
: ELOOP 40 ; inline
: EWOULDBLOCK EAGAIN ; inline
: ENOMSG 42 ; inline
: EIDRM 43 ; inline
: ECHRNG 44 ; inline
: EL2NSYNC 45 ; inline
: EL3HLT 46 ; inline
: EL3RST 47 ; inline
: ELNRNG 48 ; inline
: EUNATCH 49 ; inline
: ENOCSI 50 ; inline
: EL2HLT 51 ; inline
: EBADE 52 ; inline
: EBADR 53 ; inline
: EXFULL 54 ; inline
: ENOANO 55 ; inline
: EBADRQC 56 ; inline
: EBADSLT 57 ; inline
: EDEADLOCK EDEADLK ; inline
: EBFONT 59 ; inline
: ENOSTR 60 ; inline
: ENODATA 61 ; inline
: ETIME 62 ; inline
: ENOSR 63 ; inline
: ENONET 64 ; inline
: ENOPKG 65 ; inline
: EREMOTE 66 ; inline
: ENOLINK 67 ; inline
: EADV 68 ; inline
: ESRMNT 69 ; inline
: ECOMM 70 ; inline
: EPROTO 71 ; inline
: EMULTIHOP 72 ; inline
: EDOTDOT 73 ; inline
: EBADMSG 74 ; inline
: EOVERFLOW 75 ; inline
: ENOTUNIQ 76 ; inline
: EBADFD 77 ; inline
: EREMCHG 78 ; inline
: ELIBACC 79 ; inline
: ELIBBAD 80 ; inline
: ELIBSCN 81 ; inline
: ELIBMAX 82 ; inline
: ELIBEXEC 83 ; inline
: EILSEQ 84 ; inline
: ERESTART 85 ; inline
: ESTRPIPE 86 ; inline
: EUSERS 87 ; inline
: ENOTSOCK 88 ; inline
: EDESTADDRREQ 89 ; inline
: EMSGSIZE 90 ; inline
: EPROTOTYPE 91 ; inline
: ENOPROTOOPT 92 ; inline
: EPROTONOSUPPORT 93 ; inline
: ESOCKTNOSUPPORT 94 ; inline
: EOPNOTSUPP 95 ; inline
: EPFNOSUPPORT 96 ; inline
: EAFNOSUPPORT 97 ; inline
: EADDRINUSE 98 ; inline
: EADDRNOTAVAIL 99 ; inline
: ENETDOWN 100 ; inline
: ENETUNREACH 101 ; inline
: ENETRESET 102 ; inline
: ECONNABORTED 103 ; inline
: ECONNRESET 104 ; inline
: ENOBUFS 105 ; inline
: EISCONN 106 ; inline
: ENOTCONN 107 ; inline
: ESHUTDOWN 108 ; inline
: ETOOMANYREFS 109 ; inline
: ETIMEDOUT 110 ; inline
: ECONNREFUSED 111 ; inline
: EHOSTDOWN 112 ; inline
: EHOSTUNREACH 113 ; inline
: EALREADY 114 ; inline
: EINPROGRESS 115 ; inline
: ESTALE 116 ; inline
: EUCLEAN 117 ; inline
: ENOTNAM 118 ; inline
: ENAVAIL 119 ; inline
: EISNAM 120 ; inline
: EREMOTEIO 121 ; inline
: EDQUOT 122 ; inline
: ENOMEDIUM 123 ; inline
: EMEDIUMTYPE 124 ; inline
: ECANCELED 125 ; inline
: ENOKEY 126 ; inline
: EKEYEXPIRED 127 ; inline
: EKEYREVOKED 128 ; inline
: EKEYREJECTED 129 ; inline
: EOWNERDEAD 130 ; inline
: ENOTRECOVERABLE 131 ; inline
