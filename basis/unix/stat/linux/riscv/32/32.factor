! Copyright (C) 2026 Factor authors.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax classes.struct unix.time ;
IN: unix.stat

STRUCT: stat
    { st_dev ulonglong }
    { st_ino ulonglong }
    { st_mode uint }
    { st_nlink uint }
    { st_uid uint }
    { st_gid uint }
    { st_rdev ulonglong }
    { __pad1 ulonglong }
    { st_size longlong }
    { st_blksize int }
    { __pad2 int }
    { st_blocks longlong }
    { st_atimespec timespec }
    { st_mtimespec timespec }
    { st_ctimespec timespec }
    { __unused4 uint }
    { __unused5 uint } ;

FUNCTION-ALIAS: stat-func int stat64 ( c-string pathname, stat* buf )
FUNCTION-ALIAS: lstat int lstat64 ( c-string pathname, stat* buf )
FUNCTION-ALIAS: fstat int fstat64 ( int fd, stat* buf )
