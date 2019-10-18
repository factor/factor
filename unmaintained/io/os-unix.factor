! Copyright (C) 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays calendar errors io io-internals kernel
math nonblocking-io sequences unix-internals unix-io ;
IN: libs-io

: O_APPEND  HEX: 100 ; inline
: O_EXCL    HEX: 800 ; inline
: SEEK_SET 0 ; inline
: SEEK_CUR 1 ; inline
: SEEK_END 2 ; inline
: EEXIST 17 ; inline

FUNCTION: off_t lseek ( int fildes, off_t offset, int whence ) ;
: append-mode
    O_WRONLY O_APPEND O_CREAT bitor bitor ; foldable

: open-append ( path -- fd )
    append-mode file-mode open dup io-error
    [ 0 SEEK_END lseek io-error ] keep ;

: touch-mode
    O_WRONLY O_APPEND O_CREAT O_EXCL bitor bitor bitor ; foldable    

: open-touch ( path -- fd )
    touch-mode file-mode open
    [ io-error close t ]
    [ 2drop err_no EEXIST = [ err_no io-error ] unless -1 ] recover ;
    
: <file-appender> ( path -- stream ) open-append <writer> ;

FUNCTION: int unlink ( char* path ) ;
: delete-file ( path -- )
    unlink io-error ;

FUNCTION: int mkdir ( char* path, mode_t mode ) ;

: (create-directory) ( path mode -- )
    mkdir io-error ;

: create-directory ( path -- )
    0 (create-directory) ;

FUNCTION: int rmdir ( char* path ) ;

: delete-directory ( path -- )
    rmdir io-error ;

FUNCTION: int chroot ( char* path ) ;
FUNCTION: int chdir ( char* path ) ;
FUNCTION: int fchdir ( int fd ) ;

FUNCTION: int utimes ( char* path, timeval[2] times ) ;
FUNCTION: int futimes ( int id, timeval[2] times ) ;

TYPEDEF: longlong blkcnt_t
TYPEDEF: int blksize_t
TYPEDEF: int dev_t
TYPEDEF: uint ino_t
TYPEDEF: ushort mode_t
TYPEDEF: ushort nlink_t
TYPEDEF: uint uid_t
TYPEDEF: uint gid_t
TYPEDEF: longlong quad_t
TYPEDEF: ulong u_long

FUNCTION: int stat ( char* path, stat* sb ) ;

C-STRUCT: stat
    { "dev_t"     "dev" }       ! device inode resides on
    { "ino_t"     "ino" }       ! inode's number
    { "mode_t"    "mode" }      ! inode protection mode
    { "nlink_t"   "nlink" }     ! number or hard links to the file
    { "uid_t"     "uid" }       ! user-id of owner
    { "gid_t"     "gid" }       ! group-id of owner
    { "dev_t"     "rdev" }      ! device type, for special file inode
    { "timespec"  "atime" }     ! time of last access
    { "timespec"  "mtime" }     ! time of last data modification
    { "timespec"  "ctime" }     ! time of last file status change
    { "off_t"     "size" }      ! file size, in bytes
    { "blkcnt_t"  "blocks" }    ! blocks allocated for file
    { "blksize_t" "blksize" }   ! optimal file sys I/O ops blocksize
    { "u_long"    "flags" }     ! user defined flags for file
    { "u_long"    "gen" } ;     ! file generation number

: stat* ( path -- byte-array )
    "stat" <c-object> [ stat io-error ] keep ;

: make-timeval-array ( array -- byte-array )
    [ length "timeval" <c-array> ] keep
    dup length [ over [ pick set-timeval-nth ] [ 2drop ] if ] 2each ;

: (set-file-times) ( timestamp timestamp -- alien )
    [ [ timestamp>timeval ] [ f ] if* ] 2apply 2array
    make-timeval-array ;

: set-file-times ( path timestamp timestamp -- )
    #! set access, write
    (set-file-times) utimes io-error ;

: set-file-times* ( fd timestamp timestamp -- )
    (set-file-times) futimes io-error ;


: set-file-access-time ( path timestamp -- )
    f set-file-times ;

: set-file-write-time ( path timestamp -- )
    >r f r> set-file-times ;


: file-write-time ( path -- timestamp )
    stat* stat-mtime timespec>timestamp ;

: file-access-time ( path -- timestamp )
    stat* stat-atime timespec>timestamp ;

! File type
: S_IFMT    OCT: 0170000 ; inline ! type of file
: S_IFIFO   OCT: 0010000 ; inline ! named pipe (fifo)
: S_IFCHR   OCT: 0020000 ; inline ! character special
: S_IFDIR   OCT: 0040000 ; inline ! directory
: S_IFBLK   OCT: 0060000 ; inline ! block special
: S_IFREG   OCT: 0100000 ; inline ! regular
: S_IFLNK   OCT: 0120000 ; inline ! symbolic link
: S_IFSOCK  OCT: 0140000 ; inline ! socket
: S_IFWHT   OCT: 0160000 ; inline ! whiteout
: S_IFXATTR OCT: 0200000 ; inline ! extended attribute

! File mode
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

: S_ISUID OCT: 0004000 ; inline    ! set user id on execution
: S_ISGID OCT: 0002000 ; inline    ! set group id on execution
: S_ISVTX OCT: 0001000 ; inline    ! sticky bit

FUNCTION: uid_t getuid ;
FUNCTION: uid_t geteuid ;

FUNCTION: gid_t getgid ;
FUNCTION: gid_t getegid ;

FUNCTION: int setuid ( uid_t uid ) ;
FUNCTION: int seteuid ( uid_t euid ) ;
FUNCTION: int setreuid ( uid_t ruid, uid_t euid ) ;

FUNCTION: int setgid ( gid_t gid ) ;
FUNCTION: int setegid ( gid_t egid ) ;
FUNCTION: int setregid ( gid_t rgid, gid_t egid ) ;

FUNCTION: int issetugid ;

FUNCTION: int chmod ( char* path, mode_t mode ) ;
FUNCTION: int fchmod ( int fd, mode_t mode ) ;

FUNCTION: int chown ( char* path, uid_t owner, gid_t group ) ;
FUNCTION: int fchown ( int fd, uid_t owner, gid_t group ) ;
#! lchown does not follow symbolic links
FUNCTION: int lchown ( char* path, uid_t owner, gid_t group ) ;

FUNCTION: int getgroups ( int gidsetlen, gid_t* gidset ) ;
FUNCTION: int setgroups ( int ngroups, gid_t* gidset ) ;

FUNCTION: int flock ( int fd, int operation ) ;
! FUNCTION: int dup ( int oldd ) ;
! FUNCTION: int dup2 ( int oldd, int newd ) ;

FUNCTION: int fcntl ( int fd, int cmd, int arg ) ;
FUNCTION: int getdtablesize ;

: file-mode? ( path mask -- ? )
    >r stat* stat-mode r> bit-set? ;

: user-read? ( path -- ? ) S_IRUSR file-mode? ;
: user-write? ( path -- ? ) S_IWUSR file-mode? ;
: user-execute? ( path -- ? ) S_IXUSR file-mode? ;

: group-read? ( path -- ? ) S_IRGRP file-mode? ;
: group-write? ( path -- ? ) S_IWGRP file-mode? ;
: group-execute? ( path -- ? ) S_IXGRP file-mode? ;

: other-read? ( path -- ? ) S_IROTH file-mode? ;
: other-write? ( path -- ? ) S_IWOTH file-mode? ;
: other-execute? ( path -- ? ) S_IXOTH file-mode? ;

: set-uid? ( path -- ? ) S_ISUID bit-set? ;
: set-gid? ( path -- ? ) S_ISGID bit-set? ;
: set-sticky? ( path -- ? ) S_ISVTX bit-set? ;

: chmod* ( path mask ? -- )
    >r >r dup stat* stat-mode r> r> [
        set-bit
    ] [
        clear-bit
    ] if chmod io-error ;

: set-user-read ( path ? -- ) >r S_IRUSR r> chmod* ;
: set-user-write ( path ? -- ) >r S_IWUSR r> chmod* ;
: set-user-execute ( path ? -- ) >r S_IXUSR r> chmod* ;

: set-group-read ( path ? -- ) >r S_IRGRP r> chmod* ;
: set-group-write ( path ? -- ) >r S_IWGRP r> chmod* ;
: set-group-execute ( path ? -- ) >r S_IXGRP r> chmod* ;

: set-other-read ( path ? -- ) >r S_IROTH r> chmod* ;
: set-other-write ( path ? -- ) >r S_IWOTH r> chmod* ;
: set-other-execute ( path ? -- ) >r S_IXOTH r> chmod* ;

: set-uid ( path ? -- ) >r S_ISUID r> chmod* ;
: set-gid ( path ? -- ) >r S_ISGID r> chmod* ;
: set-sticky ( path ? -- ) >r S_ISVTX r> chmod* ;

: mode>symbol ( mode -- ch )
    S_IFMT bitand
    {
        { [ dup S_IFDIR = ] [ drop "/" ] }
        { [ dup S_IFIFO = ] [ drop "|" ] }
        { [ dup S_IXUSR = ] [ drop "*" ] }
        { [ dup S_IFLNK = ] [ drop "@" ] }
        { [ dup S_IFWHT = ] [ drop "%" ] }
        { [ dup S_IFSOCK = ] [ drop "=" ] }
        { [ t ] [ drop "" ] }
    } cond ;
