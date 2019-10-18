USING: kernel alien.c-types alien.syntax math classes.struct
unix.time unix.types ;
IN: unix.stat

! stat64
STRUCT: stat
    { st_dev dev_t }
    { __pad1 ushort }
    { __st_ino __ino_t }
    { st_mode mode_t }
    { st_nlink nlink_t }
    { st_uid uid_t }
    { st_gid gid_t }
    { st_rdev dev_t }
    { __pad2 ushort[2] }
    { st_size off64_t }
    { st_blksize blksize_t }
    { st_blocks blkcnt64_t }
    { st_atimespec timespec }
    { st_mtimespec timespec }
    { st_ctimespec timespec }
    { st_ino ulonglong } ;

FUNCTION: int __xstat64  ( int ver, c-string pathname, stat* buf )
FUNCTION: int __lxstat64 ( int ver, c-string pathname, stat* buf )
FUNCTION: int __fxstat64 ( int ver, int fd, stat* buf )

:  stat-func ( pathname buf -- int ) [ 1 ] 2dip __xstat64 ;
: lstat ( pathname buf -- int ) [ 1 ] 2dip __lxstat64 ;
: fstat ( fd buf -- int ) [ 1 ] 2dip __fxstat64 ;
