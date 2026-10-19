USING: alien.c-types alien.syntax classes.struct kernel unix.time unix.types ;
IN: unix.stat

STRUCT: stat
    { st_dev dev_t }
    { st_ino ino_t }
    { st_nlink ulong }
    { st_mode mode_t }
    { st_uid uid_t }
    { st_gid gid_t }
    { __pad0 uint }
    { st_rdev dev_t }
    { st_size off_t }
    { st_blksize long }
    { st_blocks long }
    { st_atimespec timespec }
    { st_mtimespec timespec }
    { st_ctimespec timespec }
    { __pad3 long[3] } ;

FUNCTION-ALIAS: stat-func int stat ( c-string pathname, stat* buf )
FUNCTION: int lstat ( c-string pathname, stat* buf )
FUNCTION: int fstat ( int fd, stat* buf )
