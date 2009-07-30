USING: alien.syntax alien.c-types ;
IN: unix.types

! Darwin 9.1.0

TYPEDEF: ushort   __uint16_t
TYPEDEF: uint     __uint32_t
TYPEDEF: int      __int32_t
TYPEDEF: longlong __int64_t

TYPEDEF: __int32_t  dev_t
TYPEDEF: __uint32_t ino_t
TYPEDEF: __uint16_t mode_t
TYPEDEF: __uint16_t nlink_t
TYPEDEF: __uint32_t uid_t
TYPEDEF: __uint32_t gid_t
TYPEDEF: __int64_t  off_t
TYPEDEF: __int64_t  blkcnt_t
TYPEDEF: __int64_t  ino64_t
TYPEDEF: __int32_t  blksize_t
TYPEDEF: long       ssize_t
TYPEDEF: __int32_t  pid_t
TYPEDEF: long       time_t

ALIAS: <time_t> <long>