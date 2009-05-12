USING: kernel alien.syntax math sequences unix
alien.c-types arrays accessors combinators ;
IN: unix.stat

! stat64
C-STRUCT: stat
    { "dev_t"      "st_dev" }
    { "ushort"     "__pad1" }
    { "__ino_t"     "__st_ino" }
    { "mode_t"     "st_mode" }
    { "nlink_t"    "st_nlink" }
    { "uid_t"      "st_uid" }
    { "gid_t"      "st_gid" }
    { "dev_t"      "st_rdev" }
    { { "ushort" 2 } "__pad2" }
    { "off64_t"    "st_size" }
    { "blksize_t"  "st_blksize" }
    { "blkcnt64_t" "st_blocks" }
    { "timespec"   "st_atimespec" }
    { "timespec"   "st_mtimespec" }
    { "timespec"   "st_ctimespec" }
    { "ulonglong"  "st_ino" } ;

FUNCTION: int __xstat64  ( int ver, char* pathname, stat* buf ) ;
FUNCTION: int __lxstat64 ( int ver, char* pathname, stat* buf ) ;

:  stat ( pathname buf -- int ) [ 1 ] 2dip __xstat64 ;
: lstat ( pathname buf -- int ) [ 1 ] 2dip __lxstat64 ;
