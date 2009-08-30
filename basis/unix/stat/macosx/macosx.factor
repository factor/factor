USING: alien.c-types arrays accessors combinators classes.struct
alien.syntax ;
IN: unix.stat

! Mac OS X ppc

! stat64 structure
STRUCT: stat
    { st_dev dev_t }
    { st_mode mode_t }
    { st_nlink nlink_t }
    { st_ino ino64_t }
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
    { st_flags __uint32_t }
    { st_gen __uint32_t }
    { st_lspare __int32_t }
    { st_qspare0 __int64_t }
    { st_qspare1 __int64_t } ;

FUNCTION: int stat64  ( char* pathname, stat* buf ) ;
FUNCTION: int lstat64 ( char* pathname, stat* buf ) ;

: stat ( path buf -- n ) stat64 ;
: lstat ( path buf -- n ) lstat64 ;
