USING: kernel alien.c-types alien.syntax math classes.struct
unix.time unix.types ;
IN: unix.stat

! OpenBSD 4.2

STRUCT: stat
    { st_dev dev_t }
    { st_ino ino_t }
    { st_mode mode_t }
    { st_nlink nlink_t }
    { st_uid uid_t }
    { st_gid gid_t }
    { st_rdev dev_t }
    { st_lspare0 int32_t }
    { st_atimespec timespec }
    { st_mtimespec timespec }
    { st_ctimespec timespec }
    { st_size off_t }
    { st_blocks int64_t }
    { st_blksize u_int32_t }
    { st_flags u_int32_t }
    { st_gen u_int32_t }
    { st_lspare1 int32_t }
    { st_birthtimespec timespec }
    { st_qspare int64_t[2] } ;

FUNCTION: int stat  ( char* pathname, stat* buf ) ;
FUNCTION: int lstat ( char* pathname, stat* buf ) ;
