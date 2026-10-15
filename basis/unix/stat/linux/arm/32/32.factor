USING: alien.c-types alien.syntax classes.struct unix.time unix.types ;
IN: unix.stat

! Linux ARM EABI glibc stat64; native size 104, alignment 8.
STRUCT: stat
    { st_dev dev_t }
    { __pad1 uint }
    { __st_ino __ino_t }
    { st_mode mode_t }
    { st_nlink uint }
    { st_uid uid_t }
    { st_gid gid_t }
    { st_rdev dev_t }
    { __pad2 uint }
    { st_size off64_t }
    { st_blksize blksize_t }
    { st_blocks blkcnt64_t }
    { st_atimespec timespec }
    { st_mtimespec timespec }
    { st_ctimespec timespec }
    { st_ino ino64_t } ;

FUNCTION-ALIAS: stat-func int stat64 ( c-string pathname, stat* buf )
FUNCTION-ALIAS: lstat int lstat64 ( c-string pathname, stat* buf )
FUNCTION-ALIAS: fstat int fstat64 ( int fd, stat* buf )
