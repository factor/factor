
USING: kernel system combinators alien.syntax alien.c-types
       math io.unix.backend vocabs.loader ;

IN: unix.stat

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! File Types
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

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! File Access Permissions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Read, write, execute/search by owner
: S_IRWXU OCT: 0000700 ; inline    ! rwx mask owner
: S_IRUSR OCT: 0000400 ; inline    ! r owner
: S_IWUSR OCT: 0000200 ; inline    ! w owner
: S_IXUSR OCT: 0000100 ; inline    ! x owner
! Read, write, execute/search by group
: S_IRWXG OCT: 0000070 ; inline    ! rwx mask group
: S_IRGRP OCT: 0000040 ; inline    ! r group
: S_IWGRP OCT: 0000020 ; inline    ! w group
: S_IXGRP OCT: 0000010 ; inline    ! x group
! Read, write, execute/search by others
: S_IRWXO OCT: 0000007 ; inline    ! rwx mask other
: S_IROTH OCT: 0000004 ; inline    ! r other
: S_IWOTH OCT: 0000002 ; inline    ! w other
: S_IXOTH OCT: 0000001 ; inline    ! x other

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

FUNCTION: int chmod ( char* path, mode_t mode ) ;

FUNCTION: int fchmod ( int fd, mode_t mode ) ;

FUNCTION: int mkdir ( char* path, mode_t mode ) ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
<<
  os
  {
    { "linux"  [ "unix.stat.linux"  require ] }
    { "macosx" [ "unix.stat.macosx" require ] }
    [ drop ]
  }
  case
>>
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: check-status ( n -- ) io-error ;

: stat* ( pathname -- stat )
  "stat" <c-object> dup >r
    stat check-status
  r> ;

: lstat* ( pathname -- stat )
  "stat" <c-object> dup >r
    lstat check-status
  r> ;
