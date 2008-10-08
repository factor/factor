USING: alien.syntax alien.c-types math ;
IN: unix

: FD_SETSIZE 256 ; inline

C-STRUCT: addrinfo
    { "int" "flags" }
    { "int" "family" } 
    { "int" "socktype" }
    { "int" "protocol" }
    { "socklen_t" "addrlen" }
    { "char*" "canonname" }
    { "void*" "addr" }
    { "addrinfo*" "next" } ;

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
: EDEADLK 11 ; inline
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
: EAGAIN 35 ; inline
: EWOULDBLOCK EAGAIN ; inline
: EINPROGRESS 36 ; inline
: EALREADY 37 ; inline
: ENOTSOCK 38 ; inline
: EDESTADDRREQ 39 ; inline
: EMSGSIZE 40 ; inline
: EPROTOTYPE 41 ; inline
: ENOPROTOOPT 42 ; inline
: EPROTONOSUPPORT 43 ; inline
: ESOCKTNOSUPPORT 44 ; inline
: EOPNOTSUPP 45 ; inline
: EPFNOSUPPORT 46 ; inline
: EAFNOSUPPORT 47 ; inline
: EADDRINUSE 48 ; inline
: EADDRNOTAVAIL 49 ; inline
: ENETDOWN 50 ; inline
: ENETUNREACH 51 ; inline
: ENETRESET 52 ; inline
: ECONNABORTED 53 ; inline
: ECONNRESET 54 ; inline
: ENOBUFS 55 ; inline
: EISCONN 56 ; inline
: ENOTCONN 57 ; inline
: ESHUTDOWN 58 ; inline
: ETOOMANYREFS 59 ; inline
: ETIMEDOUT 60 ; inline
: ECONNREFUSED 61 ; inline
: ELOOP 62 ; inline
: ENAMETOOLONG 63 ; inline
: EHOSTDOWN 64 ; inline
: EHOSTUNREACH 65 ; inline
: ENOTEMPTY 66 ; inline
: EPROCLIM 67 ; inline
: EUSERS 68 ; inline
: EDQUOT 69 ; inline
: ESTALE 70 ; inline
: EREMOTE 71 ; inline
: EBADRPC 72 ; inline
: ERPCMISMATCH 73 ; inline
: EPROGUNAVAIL 74 ; inline
: EPROGMISMATCH 75 ; inline
: EPROCUNAVAIL 76 ; inline
: ENOLCK 77 ; inline
: ENOSYS 78 ; inline
: EFTYPE 79 ; inline
: EAUTH 80 ; inline
: ENEEDAUTH 81 ; inline
: EIDRM 82 ; inline
: ENOMSG 83 ; inline
: EOVERFLOW 84 ; inline
: EILSEQ 85 ; inline
: ENOTSUP 86 ; inline
: ECANCELED 87 ; inline
: EBADMSG 88 ; inline
: ENODATA 89 ; inline
: ENOSR 90 ; inline
: ENOSTR 91 ; inline
: ETIME 92 ; inline
: ENOATTR 93 ; inline
: EMULTIHOP 94 ; inline
: ENOLINK 95 ; inline
: EPROTO 96 ; inline
: ELAST 96 ; inline

TYPEDEF: __uint8_t sa_family_t

: _UTX_USERSIZE   32 ; inline
: _UTX_LINESIZE   32 ; inline
: _UTX_IDSIZE     4 ; inline
: _UTX_HOSTSIZE   256 ; inline

: _SS_MAXSIZE ( -- n )
    128 ; inline

: _SS_ALIGNSIZE ( -- n )
    "__int64_t" heap-size ; inline
    
: _SS_PAD1SIZE ( -- n )
    _SS_ALIGNSIZE 2 - ; inline
    
: _SS_PAD2SIZE ( -- n )
    _SS_MAXSIZE 2 - _SS_PAD1SIZE - _SS_ALIGNSIZE - ; inline

C-STRUCT: sockaddr_storage
    { "__uint8_t" "ss_len" }
    { "sa_family_t" "ss_family" }
    { { "char" _SS_PAD1SIZE } "__ss_pad1" }
    { "__int64_t" "__ss_align" }
    { { "char" _SS_PAD2SIZE } "__ss_pad2" } ;

C-STRUCT: exit_struct
    { "uint16_t" "e_termination" }
    { "uint16_t" "e_exit" } ;

C-STRUCT: utmpx
    { { "char" _UTX_USERSIZE } "ut_user" }
    { { "char" _UTX_IDSIZE } "ut_id" }
    { { "char" _UTX_LINESIZE } "ut_line" }
    { { "char" _UTX_HOSTSIZE } "ut_host" }
    { "uint16_t" "ut_session" }
    { "uint16_t" "ut_type" }
    { "pid_t" "ut_pid" }
    { "exit_struct" "ut_exit" }
    { "sockaddr_storage" "ut_ss" }
    { "timeval" "ut_tv" }
    { { "uint32_t" 10 } "ut_pad" } ;
