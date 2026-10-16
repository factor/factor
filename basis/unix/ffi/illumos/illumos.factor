USING: alien.c-types alien.syntax classes.struct unix.types ;
IN: unix.ffi

CONSTANT: MAXPATHLEN 1024
FUNCTION: int getgrouplist ( c-string name, gid_t basegid, gid_t* groups, int* ngroups )
FUNCTION: int setgroups ( int ngroups, gid_t* gidset )

! The public names retain the legacy four-argument Solaris ABI unless
! feature-test macros rewrite them at compile time. Factor uses POSIX's
! five-argument interface directly.
FUNCTION-ALIAS: getgrgid_r int __posix_getgrgid_r (
    gid_t gid, group* grp, c-string buffer, size_t bufsize, group** result
)
FUNCTION-ALIAS: getgrnam_r int __posix_getgrnam_r (
    c-string name, group* grp, c-string buffer, size_t bufsize, group** result
)

CONSTANT: O_RDONLY 0
CONSTANT: O_WRONLY 1
CONSTANT: O_RDWR 2
CONSTANT: O_APPEND 0x8
CONSTANT: O_CREAT 0x100
CONSTANT: O_TRUNC 0x200
CONSTANT: O_EXCL 0x400
CONSTANT: O_NOCTTY 0x800
CONSTANT: O_NONBLOCK 0x80
ALIAS: O_NDELAY O_NONBLOCK
CONSTANT: F_GETFD 1
CONSTANT: F_SETFD 2
CONSTANT: F_GETFL 3
CONSTANT: F_SETFL 4
CONSTANT: FD_CLOEXEC 1
CONSTANT: FD_SETSIZE 65536

CONSTANT: SOL_SOCKET 0xffff
CONSTANT: SO_DEBUG 0x1
CONSTANT: SO_REUSEADDR 0x4
CONSTANT: SO_TYPE 0x1008
CONSTANT: SO_ERROR 0x1007
CONSTANT: SO_DONTROUTE 0x10
CONSTANT: SO_BROADCAST 0x20
CONSTANT: SO_SNDBUF 0x1001
CONSTANT: SO_RCVBUF 0x1002
CONSTANT: SO_KEEPALIVE 0x8
CONSTANT: SO_OOBINLINE 0x100
CONSTANT: SO_SNDTIMEO 0x1005
CONSTANT: SO_RCVTIMEO 0x1006

STRUCT: addrinfo
    { flags int }
    { family int }
    { socktype int }
    { protocol int }
    { addrlen socklen_t }
    { canonname c-string }
    { addr void* }
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
    { scopeid uint }
    { srcid uint } ;
CONSTANT: max-un-path 108
STRUCT: sockaddr-un
    { family ushort }
    { path { char max-un-path } } ;

CONSTANT: SOCK_STREAM 2
CONSTANT: SOCK_DGRAM 1
CONSTANT: SOCK_RAW 4
CONSTANT: AF_UNSPEC 0
CONSTANT: AF_UNIX 1
CONSTANT: AF_INET 2
CONSTANT: AF_INET6 26
ALIAS: PF_UNSPEC AF_UNSPEC
ALIAS: PF_UNIX AF_UNIX
ALIAS: PF_INET AF_INET
ALIAS: PF_INET6 AF_INET6
CONSTANT: IPPROTO_TCP 6
CONSTANT: IPPROTO_UDP 17
CONSTANT: EAI_SYSTEM 9
CONSTANT: SEEK_SET 0
CONSTANT: SEEK_CUR 1
CONSTANT: SEEK_END 2

STRUCT: passwd
    { pw_name c-string }
    { pw_passwd c-string }
    { pw_uid uid_t }
    { pw_gid gid_t }
    { pw_age c-string }
    { pw_comment c-string }
    { pw_gecos c-string }
    { pw_dir c-string }
    { pw_shell c-string } ;
STRUCT: dirent
    { d_ino ino_t }
    { d_off off_t }
    { d_reclen ushort }
    ! The C declaration uses a one-byte trailing array, but readdir_r writes
    ! the complete name into caller-owned storage.
    { d_name char[MAXPATHLEN] } ;
