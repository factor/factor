USING: kernel alien.c-types alien.syntax math classes.struct unix.time
unix.types ;
IN: unix.stat

! FreeBSD 12

! stat64 structure

STRUCT: stat
    { st_dev dev_t }
    { st_ino ino_t }
    { st_mode mode_t }
    { st_nlink nlink_t }
    { st_uid uid_t }
    { st_gid gid_t }
    { st_rdev dev_t }
    { st_atimespec timespec }
    { st_mtimespec timespec }
    { st_ctimespec timespec }
    { st_size off_t }
    { st_blocks blkcnt_t }
    { st_blksize blksize_t }
    { st_flags fflags_t }
    { st_gen __uint64_t }
    { st_spare __int64_t }
    { st_birthtimespec timespec }
    { pad0 __int32_t[2] } ;

FUNCTION-ALIAS: stat-func int stat64  ( c-string pathname, stat* buf ) 
FUNCTION-ALIAS: lstat int lstat64 ( c-string pathname, stat* buf )
FUNCTION-ALIAS: fstat int fstat64 ( int fd, stat* buf )



