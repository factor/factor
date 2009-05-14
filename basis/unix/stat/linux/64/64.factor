USING: kernel alien.syntax math sequences unix
alien.c-types arrays accessors combinators ;
IN: unix.stat

! Ubuntu 7.10 64-bit

C-STRUCT: stat
    { "dev_t"     "st_dev" }
    { "ino_t"     "st_ino" }
    { "nlink_t"   "st_nlink" }
    { "mode_t"    "st_mode" }
    { "uid_t"     "st_uid" }
    { "gid_t"     "st_gid" }
    { "int"       "pad0" }
    { "dev_t"     "st_rdev" }
    { "off64_t"     "st_size" }
    { "blksize_t" "st_blksize" }
    { "blkcnt64_t"  "st_blocks" }
    { "timespec"  "st_atimespec" }
    { "timespec"  "st_mtimespec" }
    { "timespec"  "st_ctimespec" }
    { "long"      "__unused0" }
    { "long"      "__unused1" }
    { "long"      "__unused2" } ;

FUNCTION: int __xstat64  ( int ver, char* pathname, stat* buf ) ;
FUNCTION: int __lxstat64 ( int ver, char* pathname, stat* buf ) ;

:  stat ( pathname buf -- int ) [ 1 ] 2dip __xstat64 ;
: lstat ( pathname buf -- int ) [ 1 ] 2dip __lxstat64 ;
