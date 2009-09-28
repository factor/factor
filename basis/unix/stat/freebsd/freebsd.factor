USING: kernel alien.c-types alien.syntax math classes.struct
unix.time unix.types ;
IN: unix.stat

! FreeBSD 8.0-CURRENT

STRUCT: stat
    { st_dev __dev_t }
    { st_ino ino_t }
    { st_mode mode_t }
    { st_nlink nlink_t }
    { st_uid uid_t }
    { st_gid gid_t }
    { st_rdev __dev_t }
    { st_atimespec timespec }
    { st_mtimespec timespec }
    { st_ctimespec timespec }
    { st_size off_t }
    { st_blocks blkcnt_t }
    { st_blksize blksize_t }
    { st_flags fflags_t }
    { st_gen __uint32_t }
    { st_lspare __int32_t }
    { st_birthtimespec timespec }
    { pad0 __int32_t[2] } ;

FUNCTION: int stat  ( char* pathname, stat* buf ) ;
FUNCTION: int lstat ( char* pathname, stat* buf ) ;
