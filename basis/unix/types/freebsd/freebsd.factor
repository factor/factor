USING: alien.syntax alien.c-types ;

IN: unix.types

! FreeBSD 7 x86.32

TYPEDEF: ushort          __uint16_t
TYPEDEF: uint           __uint32_t
TYPEDEF: int            __int32_t
TYPEDEF: longlong       __int64_t

TYPEDEF: __uint32_t     __dev_t
TYPEDEF: __uint32_t     ino_t
TYPEDEF: __uint16_t     mode_t
TYPEDEF: __uint16_t     nlink_t
TYPEDEF: __uint32_t     uid_t
TYPEDEF: __uint32_t     gid_t
TYPEDEF: __int64_t      off_t
TYPEDEF: __int64_t      blkcnt_t
TYPEDEF: __uint32_t     blksize_t
TYPEDEF: __uint32_t     fflags_t
TYPEDEF: long           ssize_t
TYPEDEF: int            pid_t
TYPEDEF: int            time_t

ALIAS: <time_t> <int>
