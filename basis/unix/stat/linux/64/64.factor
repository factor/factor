USING: kernel alien.c-types alien.syntax math classes.struct
unix.time unix.types system ;
IN: unix.stat

! Ubuntu 7.10 64-bit

STRUCT: stat
    { st_dev dev_t }
    { st_ino ino_t }
    { st_nlink nlink_t }
    { st_mode mode_t }
    { st_uid uid_t }
    { st_gid gid_t }
    { pad0 int }
    { st_rdev dev_t }
    { st_size off64_t }
    { st_blksize blksize_t }
    { st_blocks blkcnt64_t }
    { st_atimespec timespec }
    { st_mtimespec timespec }
    { st_ctimespec timespec }
    { __unused0 long[3] } ;

FUNCTION: int __xstat64  ( int ver, c-string pathname, stat* buf )
FUNCTION: int __lxstat64 ( int ver, c-string pathname, stat* buf )
FUNCTION: int __fxstat64 ( int ver, int fd, stat* buf )

: ver ( -- n ) cpu arm.64? 0 1 ? ;

:  stat-func ( pathname buf -- int ) [ ver ] 2dip __xstat64 ;
: lstat ( pathname buf -- int ) [ ver ] 2dip __lxstat64 ;
: fstat ( fd buf -- int ) [ ver ] 2dip __fxstat64 ;
