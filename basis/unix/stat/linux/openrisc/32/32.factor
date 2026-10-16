! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax classes.struct unix.time unix.types ;
IN: unix.stat

! OpenRISC glibc stat/stat64: 128 bytes, aligned to four bytes.
STRUCT: stat
    { st_dev dev_t }
    { st_ino ino64_t }
    { st_mode mode_t }
    { st_nlink nlink_t }
    { st_uid uid_t }
    { st_gid gid_t }
    { st_rdev dev_t }
    { __pad1 dev_t }
    { st_size off64_t }
    { st_blksize blksize_t }
    { __pad2 int }
    { st_blocks blkcnt64_t }
    { st_atimespec timespec }
    { st_mtimespec timespec }
    { st_ctimespec timespec }
    { __reserved int[2] } ;

FUNCTION-ALIAS: stat-func int stat64 ( c-string pathname, stat* buf )
FUNCTION-ALIAS: lstat int lstat64 ( c-string pathname, stat* buf )
FUNCTION-ALIAS: fstat int fstat64 ( int fd, stat* buf )
