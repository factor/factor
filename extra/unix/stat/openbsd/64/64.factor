USING: kernel alien.syntax math ;
IN: unix.stat

! OpenBSD 4.2

C-STRUCT: stat
    { "dev_t" "st_dev" }
    { "ino_t" "st_ino" }
    { "mode_t" "st_mode" }
    { "nlink_t" "st_nlink" }
    { "uid_t" "st_uid" }
    { "gid_t" "st_gid" }
    { "dev_t" "st_rdev" }
    { "int32_t" "st_lspare0" }
    { "timespec*" "st_atimespec" }
    { "timespec*" "st_mtimespec" }
    { "timespec*" "st_ctimespec" }
    { "off_t" "st_size" }
    { "int64_t" "st_blocks" }
    { "u_int32_t" "st_blksize" }
    { "u_int32_t" "st_flags" }
    { "u_int32_t" "st_gen" }
    { "int32_t" "st_lspare1" }
    { "timespec*" "st_birthtimespec" }
    { "int64_t" "st_qspare1" }
    { "int64_t" "st_qspare2" } ;

FUNCTION: int stat  ( char* pathname, stat* buf ) ;
FUNCTION: int lstat ( char* pathname, stat* buf ) ;
