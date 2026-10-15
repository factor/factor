! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax classes.struct unix.time unix.types ;
IN: unix.stat

! GNU PowerPC ELF64 stat64, both byte orders: 144 bytes, alignment 8.
STRUCT: stat
    { st_dev dev_t }
    { st_ino ino64_t }
    { st_nlink nlink_t }
    { st_mode mode_t }
    { st_uid uid_t }
    { st_gid gid_t }
    { __pad2 int }
    { st_rdev dev_t }
    { st_size off64_t }
    { st_blksize blksize_t }
    { st_blocks blkcnt64_t }
    { st_atimespec timespec }
    { st_mtimespec timespec }
    { st_ctimespec timespec }
    { __glibc_reserved4 ulong }
    { __glibc_reserved5 ulong }
    { __glibc_reserved6 ulong } ;

FUNCTION-ALIAS: stat-func int stat64 ( c-string pathname, stat* buf )
FUNCTION-ALIAS: lstat int lstat64 ( c-string pathname, stat* buf )
FUNCTION-ALIAS: fstat int fstat64 ( int fd, stat* buf )
