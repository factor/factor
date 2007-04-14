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
    { "timespec" "st_atim" }
    { "timespec" "st_mtim" }
    { "timespec" "st_ctim" }
    { "off_t" "st_size" }
    { "blkcnt_t" "st_blocks" }
    { "blksize_t" "st_blksize" }
    { "uint32_t" "st_flags" }
    { "uint32_t" "st_gen" }
    { "uint32_t" "st_spare0" }
    { "timespec" "st_birthtim" }
    { "int" "__pad5" } ;

FUNCTION: int stat  ( char* pathname, stat* buf ) ;
FUNCTION: int lstat ( char* pathname, stat* buf ) ;
