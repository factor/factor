USING: alien.c-types alien.syntax classes.struct unix.time ;
IN: unix.stat

! GNU MIPS stat64, independently checked against native C layout probes.
STRUCT: stat
    { st_dev ulong }
    { __pad1 long[3] }
    { st_ino ulonglong }
    { st_mode uint }
    { st_nlink ulong }
    { st_uid uint }
    { st_gid uint }
    { st_rdev ulong }
    { __pad2 long[3] }
    { st_size longlong }
    { st_atimespec timespec }
    { st_mtimespec timespec }
    { st_ctimespec timespec }
    { st_blksize long }
    { __pad3 long }
    { st_blocks longlong }
    { __pad4 long[14] } ;

FUNCTION-ALIAS: stat-func int stat64 ( c-string pathname, stat* buf )
FUNCTION-ALIAS: lstat int lstat64 ( c-string pathname, stat* buf )
FUNCTION-ALIAS: fstat int fstat64 ( int fd, stat* buf )
