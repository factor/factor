USING: kernel alien.syntax math ;
IN: unix.stat

! Mac OS X ppc

! stat64 structure
C-STRUCT: stat
    { "dev_t"      "st_dev" }
    { "mode_t"     "st_mode" }
    { "nlink_t"    "st_nlink" }
    { "ino_t"      "st_ino" }
    { "uid_t"      "st_uid" }
    { "gid_t"      "st_gid" }
    { "dev_t"      "st_rdev" }
    { "timespec"   "st_atimespec" }
    { "timespec"   "st_mtimespec" }
    { "timespec"   "st_ctimespec" }
    { "timespec"   "st_birthtimespec" }
    { "off_t"      "st_size" }
    { "blkcnt_t"   "st_blocks" }
    { "blksize_t"  "st_blksize" }
    { "__uint32_t" "st_flags" }
    { "__uint32_t" "st_gen" }
    { "__int32_t"  "st_lspare" }
    { "__int64_t"  "st_qspare0" }
    { "__int64_t"  "st_qspare1" } ;

FUNCTION: int stat64  ( char* pathname, stat* buf ) ;
FUNCTION: int lstat64 ( char* pathname, stat* buf ) ;

: stat ( path buf -- n ) stat64 ;
: lstat ( path buf -- n ) lstat64 ;
