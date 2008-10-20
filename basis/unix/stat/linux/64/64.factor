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
    { "off_t"     "st_size" }
    { "blksize_t" "st_blksize" }
    { "blkcnt_t"  "st_blocks" }
    { "timespec"  "st_atimespec" }
    { "timespec"  "st_mtimespec" }
    { "timespec"  "st_ctimespec" }
    { "long"      "__unused0" }
    { "long"      "__unused1" }
    { "long"      "__unused2" } ;

FUNCTION: int __xstat  ( int ver, char* pathname, stat* buf ) ;
FUNCTION: int __lxstat ( int ver, char* pathname, stat* buf ) ;

:  stat ( pathname buf -- int ) 1 -rot __xstat ;
: lstat ( pathname buf -- int ) 1 -rot __lxstat ;

TYPEDEF: ssize_t __SWORD_TYPE
TYPEDEF: ulonglong __fsblkcnt64_t
TYPEDEF: ulonglong __fsfilcnt64_t

C-STRUCT: statfs64
    { "__SWORD_TYPE" "f_type" }
    { "__SWORD_TYPE" "f_bsize" }
    { "__fsblkcnt64_t" "f_blocks" }
    { "__fsblkcnt64_t" "f_bfree" }
    { "__fsblkcnt64_t" "f_bavail" }
    { "__fsfilcnt64_t" "f_files" }
    { "__fsfilcnt64_t" "f_ffree" }
    { "__fsid_t" "f_fsid" }
    { "__SWORD_TYPE" "f_namelen" }
    { "__SWORD_TYPE" "f_frsize" }
    { { "__SWORD_TYPE" 5 } "f_spare" } ;

FUNCTION: int statfs64 ( char* path, statfs64* buf ) ;
