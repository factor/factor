! Copyright (C) 2010 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax classes.struct kernel literals system
unix.time unix.types vocabs ;
IN: unix.ffi

CONSTANT: MAXPATHLEN 4096

FUNCTION: int getgrouplist ( c-string name, gid_t basegid, gid_t* groups, int* ngroups )
FUNCTION: int setgroups ( size_t ngroups, gid_t* gidset )

! Linux MIPS and PA-RISC retain traditional open/socket constants.
CONSTANT: O_RDONLY   0x0000
CONSTANT: O_WRONLY   0x0001
CONSTANT: O_RDWR     0x0002
CONSTANT: O_CREAT $[ cpu mips? cpu hppa? or 0x100 0x40 ? ]
CONSTANT: O_EXCL $[ cpu mips? cpu hppa? or 0x400 0x80 ? ]
CONSTANT: O_NOCTTY $[ cpu hppa? [ 0x20000 ] [ cpu mips? 0x800 0x100 ? ] if ]
CONSTANT: O_TRUNC    0x0200
CONSTANT: O_APPEND $[ cpu mips? cpu hppa? or 0x8 0x400 ? ]
CONSTANT: O_NONBLOCK $[ cpu hppa? [ 0x10000 ] [ cpu mips? 0x80 0x800 ? ] if ]

ALIAS: O_NDELAY O_NONBLOCK

CONSTANT: SOL_SOCKET $[ cpu mips? cpu hppa? or 0xffff 0x1 ? ]

CONSTANT: FD_SETSIZE 1024

CONSTANT: SO_DEBUG 1
CONSTANT: SO_REUSEADDR $[ cpu mips? cpu hppa? or 0x4 0x2 ? ]
CONSTANT: SO_TYPE $[ cpu mips? cpu hppa? or 0x1008 0x3 ? ]
CONSTANT: SO_ERROR $[ cpu mips? cpu hppa? or 0x1007 0x4 ? ]
CONSTANT: SO_DONTROUTE $[ cpu mips? cpu hppa? or 0x10 0x5 ? ]
CONSTANT: SO_BROADCAST $[ cpu mips? cpu hppa? or 0x20 0x6 ? ]
CONSTANT: SO_SNDBUF $[ cpu mips? cpu hppa? or 0x1001 0x7 ? ]
CONSTANT: SO_RCVBUF $[ cpu mips? cpu hppa? or 0x1002 0x8 ? ]
CONSTANT: SO_KEEPALIVE $[ cpu mips? cpu hppa? or 0x8 0x9 ? ]
ALIAS: SO_KEEPALINE SO_KEEPALIVE
CONSTANT: SO_OOBINLINE $[ cpu mips? cpu hppa? or 0x100 0xa ? ]
CONSTANT: SO_SNDTIMEO $[ cpu mips? cpu hppa? or 0x1005 0x15 ? ]
CONSTANT: SO_RCVTIMEO $[ cpu mips? cpu hppa? or 0x1006 0x14 ? ]

CONSTANT: F_SETFD 2
CONSTANT: FD_CLOEXEC 1
CONSTANT: F_GETFD 1

CONSTANT: F_GETFL 3
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
    { unused char[8] } ;

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

CONSTANT: SOCK_STREAM $[ cpu mips? 0x2 0x1 ? ]
CONSTANT: SOCK_DGRAM $[ cpu mips? 0x1 0x2 ? ]
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

CONSTANT: EAI_SYSTEM -11

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

FUNCTION: int open64 ( c-string path, int flags, ... int prot )
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

! x86 and MIPS glibc share the on-disk format between 32- and 64-bit
! processes. AArch64 uses the native long/timeval layout instead.
C-TYPE: utmpx-session
C-TYPE: utmpx-seconds
<<
cpu x86? cpu mips? or int long ? \ utmpx-session typedef
cpu mips? [ int ] [ cpu x86? uint long ? ] if \ utmpx-seconds typedef
>>
STRUCT: utmpx-timeval
    { sec utmpx-seconds }
    { usec utmpx-session } ;

STRUCT: utmpx
    { ut_type short }
    { ut_pid pid_t }
    { ut_line char[__UT_LINESIZE] }
    { ut_id char[4] }
    { ut_user char[__UT_NAMESIZE] }
    { ut_host char[__UT_HOSTSIZE] }
    { ut_exit exit_status }
    { ut_session utmpx-session }
    { ut_tv utmpx-timeval }
    { ut_addr_v6 int[4] }
    { __unused char[20] } ;

cpu alpha.64? [ "unix.ffi.linux.alpha" require ] when

cpu sparc? [ "unix.ffi.linux.sparc" require ] when

cpu x86.64? [ "unix.ffi.linux.x86.64" require ] when
