USING: alien.c-types alien.syntax classes.struct kernel
unix.time unix.types ;
IN: unix.stat

! Linux x86-64 uses this layout with both glibc and musl.

STRUCT: stat
    { st_dev dev_t }
    { st_ino ino_t }
    { st_nlink nlink_t }
    { st_mode mode_t }
    { st_uid uid_t }
    { st_gid gid_t }
    { pad0 int }
    { st_rdev dev_t }
    { st_size off64_t }
    { st_blksize blksize_t }
    { st_blocks blkcnt64_t }
    { st_atimespec timespec }
    { st_mtimespec timespec }
    { st_ctimespec timespec }
    { __unused0 long[3] } ;

FUNCTION-ALIAS: stat-func int stat ( c-string pathname, stat* buf )
FUNCTION: int lstat ( c-string pathname, stat* buf )
FUNCTION: int fstat ( int fd, stat* buf )
