USING: kernel system combinators alien.syntax alien.c-types
math io.unix.backend vocabs.loader unix ;
IN: unix.stat

! File Types

: S_IFMT   OCT: 170000 ; ! These bits determine file type.

: S_IFDIR  OCT:  40000 ; inline   ! Directory.
: S_IFCHR  OCT:  20000 ; inline   ! Character device.
: S_IFBLK  OCT:  60000 ; inline   ! Block device.
: S_IFREG  OCT: 100000 ; inline   ! Regular file.
: S_IFIFO  OCT: 010000 ; inline   ! FIFO.
: S_IFLNK  OCT: 120000 ; inline   ! Symbolic link.
: S_IFSOCK OCT: 140000 ; inline   ! Socket.

! File Access Permissions
: S_ISUID OCT: 0004000 ; inline
: S_ISGID OCT: 0002000 ; inline
: S_ISVTX OCT: 0001000 ; inline
: S_IRUSR OCT: 0000400 ; inline    ! r owner
: S_IWUSR OCT: 0000200 ; inline    ! w owner
: S_IXUSR OCT: 0000100 ; inline    ! x owner
: S_IRGRP OCT: 0000040 ; inline    ! r group
: S_IWGRP OCT: 0000020 ; inline    ! w group
: S_IXGRP OCT: 0000010 ; inline    ! x group
: S_IROTH OCT: 0000004 ; inline    ! r other
: S_IWOTH OCT: 0000002 ; inline    ! w other
: S_IXOTH OCT: 0000001 ; inline    ! x other

FUNCTION: int chmod ( char* path, mode_t mode ) ;
FUNCTION: int fchmod ( int fd, mode_t mode ) ;
FUNCTION: int mkdir ( char* path, mode_t mode ) ;

<< os {
    { linux   [ "unix.stat.linux"   require ] }
    { macosx  [ "unix.stat.macosx"  require ] }
    { freebsd [ "unix.stat.freebsd" require ] }
    { netbsd  [ "unix.stat.netbsd"  require ] }
    { openbsd [ "unix.stat.openbsd" require ] }
} case >>

: file-status ( pathname -- stat )
    "stat" <c-object> [
        [ stat ] unix-system-call drop
    ] keep ;

: link-status ( pathname -- stat )
    "stat" <c-object> [
        [ lstat ] unix-system-call drop
    ] keep ;
