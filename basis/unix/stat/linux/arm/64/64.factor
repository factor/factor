USING: alien.c-types alien.syntax classes.struct kernel
unix.time ;
IN: unix.stat

STRUCT: stat
    { st_dev ulong }
    { st_ino ulong }
    { st_mode uint }
    { st_nlink uint }
    { st_uid uint }
    { st_gid uint }
    { st_rdev ulong }
    { __pad1 ulong }
    { st_size long }
    { st_blksize int }
    { __pad2 int }
    { st_blocks long }
    { st_atimespec timespec }
    { st_mtimespec timespec }
    { st_ctimespec timespec }
    { __unused4 uint }
    { __unused5 uint } ;

FUNCTION: int __xstat64  ( int ver, c-string pathname, stat* buf )
FUNCTION: int __lxstat64 ( int ver, c-string pathname, stat* buf )
FUNCTION: int __fxstat64 ( int ver, int fd, stat* buf )

:  stat-func ( pathname buf -- int ) [ 0 ] 2dip __xstat64 ;
: lstat ( pathname buf -- int ) [ 0 ] 2dip __lxstat64 ;
: fstat ( fd buf -- int ) [ 0 ] 2dip __fxstat64 ;
