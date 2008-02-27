
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
    { "timespec"  "st_atim" }
    { "timespec"  "st_mtim" }
    { "timespec"  "st_ctim" }
    { "ulong"     "unused4" }
    { "ulong"     "unused5" } ;

FUNCTION: int __xstat  ( int ver, char* pathname, stat* buf ) ;
FUNCTION: int __lxstat ( int ver, char* pathname, stat* buf ) ;

:  stat ( pathname buf -- int ) 3 -rot __xstat ;
: lstat ( pathname buf -- int ) 3 -rot __lxstat ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: S_IFMT   OCT: 170000 ; ! These bits determine file type.

: S_IFDIR  OCT:  40000 ;    ! Directory.
: S_IFCHR  OCT:  20000 ;    ! Character device.
: S_IFBLK  OCT:  60000 ;    ! Block device.
: S_IFREG  OCT: 100000 ;    ! Regular file.
: S_IFIFO  OCT: 010000 ;    ! FIFO.
: S_IFLNK  OCT: 120000 ;    ! Symbolic link.
: S_IFSOCK OCT: 140000 ;    ! Socket.

: S_ISTYPE ( mode mask -- val ) >r S_IFMT bitand r> = ;

: S_ISREG  ( mode -- value ) S_IFREG S_ISTYPE ;
: S_ISDIR  ( mode -- value ) S_IFDIR S_ISTYPE ;
: S_ISCHR  ( mode -- value ) S_IFCHR S_ISTYPE ;
: S_ISBLK  ( mode -- value ) S_IFBLK S_ISTYPE ;
: S_ISFIFO ( mode -- value ) S_IFIFO S_ISTYPE ;
: S_ISLNK  ( mode -- value ) S_IFLNK S_ISTYPE ;
: S_ISSOCK ( mode -- value ) S_IFSOCK S_ISTYPE ;

