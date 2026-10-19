USING: kernel alien.c-types alien.syntax math classes.struct unix.time
unix.types system ;
IN: unix.stat

! FreeBSD 12

! stat64 structure
    
! i386 reserves an extra word before each 32-bit time_t in struct stat.
STRUCT: freebsd-stat-timespec32
    { ext int }
    { sec time_t }
    { nsec long } ;

TYPEDEF: timespec freebsd-stat-time
<< cpu x86.32? \ freebsd-stat-timespec32 \ timespec ? \ freebsd-stat-time typedef >>

STRUCT: stat
    { st_dev dev_t }
    { st_ino ino_t }
    { st_nlink nlink_t }
    { st_mode mode_t }
    { st_bsdflags __int16_t }
    { st_uid uid_t }
    { st_gid gid_t }
    { st_padding1 __int32_t }
    { st_rdev dev_t }
    { st_atimespec freebsd-stat-time }
    { st_mtimespec freebsd-stat-time }
    { st_ctimespec freebsd-stat-time }
    { st_birthtimespec freebsd-stat-time }
    { st_size off_t }
    { st_blocks blkcnt_t }
    { st_blksize blksize_t }
    { st_flags fflags_t }
    { st_gen __uint64_t }
    { st_filerev __uint64_t }
    { st_spare __int64_t[9] } ;
    
FUNCTION-ALIAS: stat-func int stat  ( c-string pathname, stat* buf ) 
FUNCTION: int lstat ( c-string pathname, stat* buf )
FUNCTION: int fstat ( int fd, stat* buf )

