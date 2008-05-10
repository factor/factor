
USING: kernel alien.syntax math ;

IN: unix.stat

! Mac OS X ppc

C-STRUCT: stat
    { "dev_t"      "st_dev" }
    { "ino_t"      "st_ino" }
    { "mode_t"     "st_mode" }
    { "nlink_t"    "st_nlink" }
    { "uid_t"      "st_uid" }
    { "gid_t"      "st_gid" }
    { "dev_t"      "st_rdev" }
    { "timespec"   "st_atimespec" }
    { "timespec"   "st_mtimespec" }
    { "timespec"   "st_ctimespec" }
    { "off_t"      "st_size" }
    { "blkcnt_t"   "st_blocks" }
    { "blksize_t"  "st_blksize" }
    { "__uint32_t" "st_flags" }
    { "__uint32_t" "st_gen" }
    { "__int32_t"  "st_lspare" }
    { "__int64_t"  "st_qspare0" }
    { "__int64_t"  "st_qspare1" } ;

FUNCTION: int stat  ( char* pathname, stat* buf ) ;
FUNCTION: int lstat ( char* pathname, stat* buf ) ;

: stat-st_atim stat-st_atimespec ;
: stat-st_mtim stat-st_mtimespec ;
: stat-st_ctim stat-st_ctimespec ;
