USING: alien alien.c-types alien.libraries alien.syntax
classes.struct combinators kernel system unix unix.time
unix.types vocabs vocabs.loader ;
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

CONSTANT: SEEK_SET 0
CONSTANT: SEEK_CUR 1
CONSTANT: SEEK_END 2

CONSTANT: FD_SETSIZE 1024

CONSTANT: AF_INET6 30
ALIAS: PF_INET6 AF_INET6

STRUCT: addrinfo
    { flags int }
    { family int }
    { socktype int }
    { protocol int }
    { addrlen socklen_t }
    { canonname c-string }
    { addr void* }
    { next addrinfo* } ;

CONSTANT: _UTX_USERSIZE 256
CONSTANT: _UTX_LINESIZE 32
CONSTANT: _UTX_IDSIZE 4
CONSTANT: _UTX_HOSTSIZE 256

STRUCT: utmpx
    { ut_user { char _UTX_USERSIZE } }
    { ut_id   { char _UTX_IDSIZE   } }
    { ut_line { char _UTX_LINESIZE } }
    { ut_pid  pid_t }
    { ut_type short }
    { ut_tv   timeval }
    { ut_host { char _UTX_HOSTSIZE } }
    { ut_pad  { uint 16 } } ;

CONSTANT: __DARWIN_MAXPATHLEN 1024
CONSTANT: __DARWIN_MAXNAMELEN 255
CONSTANT: __DARWIN_MAXNAMELEN+1 256

STRUCT: dirent
    { d_ino ino_t }
    { d_reclen __uint16_t }
    { d_type __uint8_t }
    { d_namlen __uint8_t }
    { d_name { char __DARWIN_MAXNAMELEN+1 } } ;

STRUCT: sf_hdtr
    { headers void* }
    { hdr_cnt int }
    { trailers void* }
    { trl_cnt int } ;

FUNCTION: int sendfile ( int fd, int s, off_t offset, off_t* len, sf_hdtr* hdtr, int flags )

CONSTANT: XATTR_NOFOLLOW        0x0001
CONSTANT: XATTR_CREATE          0x0002
CONSTANT: XATTR_REPLACE         0x0004
CONSTANT: XATTR_NOSECURITY      0x0008
CONSTANT: XATTR_NODEFAULT       0x0010
CONSTANT: XATTR_SHOWCOMPRESSION 0x0020

CONSTANT: XATTR_MAXNAMELEN 127
CONSTANT: XATTR_FINDERINFO_NAME   "com.apple.FinderInfo"
CONSTANT: XATTR_RESOURCEFORK_NAME "com.apple.ResourceFork"
CONSTANT: XATTR_MAXSIZE 67108864 ! 64 * 1024 * 1024

FUNCTION: ssize_t getxattr ( c-string path, c-string name, void *value, size_t size, u_int32_t position, int options )
FUNCTION: ssize_t fgetxattr ( int fd, c-string name, void *value, size_t size, u_int32_t position, int options )
FUNCTION: int setxattr ( c-string path, c-string name, void *value, size_t size, u_int32_t position, int options )
FUNCTION: int fsetxattr ( int fd, c-string name, void *value, size_t size, u_int32_t position, int options )
FUNCTION: int removexattr ( c-string path, c-string name, int options )
FUNCTION: int fremovexattr ( int fd, c-string name, int options )
FUNCTION: ssize_t listxattr ( c-string path, c-string namebuf, size_t size, int options )
FUNCTION: ssize_t flistxattr ( int fd, c-string namebuf, size_t size, int options )
