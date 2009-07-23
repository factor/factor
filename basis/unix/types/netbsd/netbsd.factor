USING: alien.syntax alien.c-types combinators layouts vocabs.loader ;
IN: unix.types

! NetBSD 4.0

TYPEDEF: __uint32_t     __dev_t
TYPEDEF: __uint32_t     dev_t
TYPEDEF: __uint32_t     mode_t
TYPEDEF: __uint32_t     nlink_t
TYPEDEF: __uint32_t     uid_t
TYPEDEF: __uint32_t     __uid_t
TYPEDEF: __uint32_t     gid_t
TYPEDEF: __int64_t      off_t
TYPEDEF: __int64_t      blkcnt_t
TYPEDEF: __uint32_t     blksize_t
TYPEDEF: long           ssize_t
TYPEDEF: int            pid_t
TYPEDEF: int            time_t

ALIAS: <time_t> <int>

cell-bits {
    { 32 [ "unix.types.netbsd.32" require ] }
    { 64 [ "unix.types.netbsd.64" require ] }
} case

