USING: kernel alien.c-types alien.syntax math classes.struct
unix.time unix.types ;
IN: unix.stat

! NetBSD 4.0

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
    { st_flags uint32_t }
    { st_gen uint32_t }
    { st_qspare uint32_t[2] } ;

FUNCTION: int __stat30  ( char* pathname, stat* buf ) ;
FUNCTION: int __lstat30 ( char* pathname, stat* buf ) ;

: stat ( pathname buf -- n ) __stat30 ;
: lstat ( pathname buf -- n ) __lstat30 ;
