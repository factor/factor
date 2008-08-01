USING: kernel alien.syntax math ;
IN: unix.stat

! FreeBSD 8.0-CURRENT
! untested

C-STRUCT: stat
    { "__dev_t"    "st_dev" }
    { "ino_t"      "st_ino" }
    { "mode_t"     "st_mode" }
    { "nlink_t"    "st_nlink" }
    { "uid_t"      "st_uid" }
    { "gid_t"      "st_gid" }
    { "__dev_t"    "st_rdev" }
    { "timespec"   "st_atim" }
    { "timespec"   "st_mtim" }
    { "timespec"   "st_ctim" }
    { "off_t"      "st_size" }
    { "blkcnt_t"   "st_blocks" }
    { "blksize_t"  "st_blksize" }
    { "fflags_t"   "st_flags" }
    { "__uint32_t" "st_gen" }
    { "__int32_t"  "st_lspare" }
    { "timespec"   "st_birthtimespec" }
! not sure about the padding here.
    { "__uint32_t" "pad0" }
    { "__uint32_t" "pad1" } ;

FUNCTION: int stat  ( char* pathname, stat* buf ) ;
FUNCTION: int lstat ( char* pathname, stat* buf ) ;
