USING: alien.c-types alien.syntax classes.struct unix.time unix.types ;
IN: unix.stat

STRUCT: stat
    { st_dev dev_t }
    { st_mode mode_t }
    { st_ino ino_t }
    { st_nlink nlink_t }
    { st_uid uid_t }
    { st_gid gid_t }
    { st_rdev dev_t }
    { st_atimespec timespec }
    { st_mtimespec timespec }
    { st_ctimespec timespec }
    { st_birthtimespec timespec }
    { st_size off_t }
    { st_blocks blkcnt_t }
    { st_blksize blksize_t }
    { st_flags uint }
    { st_gen uint }
    { st_spare uint[2] }
    ;

FUNCTION-ALIAS: stat-func int __stat50 ( c-string pathname, stat* buf )
FUNCTION-ALIAS: lstat int __lstat50 ( c-string pathname, stat* buf )
FUNCTION-ALIAS: fstat int __fstat50 ( int fd, stat* buf )
