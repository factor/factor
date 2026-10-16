USING: alien.c-types alien.syntax classes.struct unix.time unix.types ;
IN: unix.stat

STRUCT: stat
    { st_dev dev_t }
    { st_ino ino_t }
    { st_mode mode_t }
    { st_nlink nlink_t }
    { st_uid uid_t }
    { st_gid gid_t }
    { st_rdev dev_t }
    { st_size off_t }
    { st_atimespec timespec }
    { st_mtimespec timespec }
    { st_ctimespec timespec }
    { st_blksize blksize_t }
    { st_blocks blkcnt_t }
    { st_fstype char[16] } ;

FUNCTION-ALIAS: stat-func int stat ( c-string pathname, stat* buf )
FUNCTION: int lstat ( c-string pathname, stat* buf )
FUNCTION: int fstat ( int fd, stat* buf )
