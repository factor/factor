
USING: kernel alien.syntax math ;

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
    { "off_t"     "st_size" }
    { "blksize_t" "st_blksize" }
    { "blkcnt_t"  "st_blocks" }
    { "timespec"  "st_atim" }
    { "timespec"  "st_mtim" }
    { "timespec"  "st_ctim" }
    { "long"      "__unused0" }
    { "long"      "__unused1" }
    { "long"      "__unused2" } ;

FUNCTION: int __xstat  ( int ver, char* pathname, stat* buf ) ;
FUNCTION: int __lxstat ( int ver, char* pathname, stat* buf ) ;

:  stat ( pathname buf -- int ) 1 -rot __xstat ;
: lstat ( pathname buf -- int ) 1 -rot __lxstat ;
