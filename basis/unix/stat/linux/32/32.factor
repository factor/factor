USING: kernel alien.syntax math ;
IN: unix.stat

! Ubuntu 8.04 32-bit

C-STRUCT: stat
    { "dev_t"     "st_dev" }
    { "ushort"    "__pad1"  }
    { "ino_t"     "st_ino" }
    { "mode_t"    "st_mode" }
    { "nlink_t"   "st_nlink" }
    { "uid_t"     "st_uid" }
    { "gid_t"     "st_gid" }
    { "dev_t"     "st_rdev" }
    { "ushort"    "__pad2" }
    { "off_t"     "st_size" }
    { "blksize_t" "st_blksize" }
    { "blkcnt_t"  "st_blocks" }
    { "timespec"  "st_atimespec" }
    { "timespec"  "st_mtimespec" }
    { "timespec"  "st_ctimespec" }
    { "ulong"     "unused4" }
    { "ulong"     "unused5" } ;

FUNCTION: int __xstat  ( int ver, char* pathname, stat* buf ) ;
FUNCTION: int __lxstat ( int ver, char* pathname, stat* buf ) ;

:  stat ( pathname buf -- int ) [ 3 ] 2dip __xstat ;
: lstat ( pathname buf -- int ) [ 3 ] 2dip __lxstat ;
