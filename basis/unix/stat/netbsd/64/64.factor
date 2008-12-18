USING: kernel alien.syntax math ;
IN: unix.stat

! NetBSD 4.0

C-STRUCT: stat
    { "dev_t" "st_dev" }
    { "ino_t" "st_ino" }
    { "mode_t" "st_mode" }
    { "nlink_t" "st_nlink" }
    { "uid_t" "st_uid" }
    { "gid_t" "st_gid" }
    { "dev_t" "st_rdev" }
    { "timespec" "st_atimespec" }
    { "timespec" "st_mtimespec" }
    { "timespec" "st_ctimespec" }
    { "off_t" "st_size" }
    { "blkcnt_t" "st_blocks" }
    { "blksize_t" "st_blksize" }
    { "uint32_t" "st_flags" }
    { "uint32_t" "st_gen" }
    { "uint32_t" "st_spare0" }
    { "timespec" "st_birthtimespec" } ;

FUNCTION: int __stat13 ( char* pathname, stat* buf ) ;
FUNCTION: int __lstat13 ( char* pathname, stat* buf ) ;

: stat ( pathname buf -- n ) __stat13 ;
: lstat ( pathname buf -- n ) __lstat13 ;
