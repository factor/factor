
USING: kernel alien.syntax math ;

IN: unix.stat

! Mac OS X ppc

C-STRUCT: stat
    { "dev_t"      "st_dev" }
    { "ino_t"      "st_ino" }
    { "mode_t"     "st_mode" }
    { "nlink_t"    "st_nlink" }
    { "uid_t"      "st_uid" }
    { "gid_t"      "st_gid" }
    { "dev_t"      "st_rdev" }
    { "timespec"   "st_atimespec" }
    { "timespec"   "st_mtimespec" }
    { "timespec"   "st_ctimespec" }
    { "off_t"      "st_size" }
    { "blkcnt_t"   "st_blocks" }
    { "blksize_t"  "st_blksize" }
    { "__uint32_t" "st_flags" }
    { "__uint32_t" "st_gen" }
    { "__int32_t"  "st_lspare" }
    { "__int64_t"  "st_qspare0" }
    { "__int64_t"  "st_qspare1" } ;

FUNCTION: int stat  ( char* pathname, stat* buf ) ;
FUNCTION: int lstat ( char* pathname, stat* buf ) ;

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

