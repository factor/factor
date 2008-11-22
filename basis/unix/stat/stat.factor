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
: S_IFWHT  OCT: 160000 ; inline   ! Whiteout.

FUNCTION: int chmod ( char* path, mode_t mode ) ;
FUNCTION: int fchmod ( int fd, mode_t mode ) ;
FUNCTION: int mkdir ( char* path, mode_t mode ) ;

C-STRUCT: fsid
    { { "int" 2 } "__val" } ;

    TYPEDEF: fsid __fsid_t
    TYPEDEF: fsid fsid_t

<< os {
    { linux   [ "unix.stat.linux"   require ] }
    { macosx  [ "unix.stat.macosx"  require ] }
    { freebsd [ "unix.stat.freebsd" require ] }
    { netbsd  [ "unix.stat.netbsd"  require ] }
    { openbsd [ "unix.stat.openbsd" require ] }
} case >>

: file-status ( pathname -- stat )
    "stat" <c-object> [ [ stat ] unix-system-call drop ] keep ;

: link-status ( pathname -- stat )
    "stat" <c-object> [ [ lstat ] unix-system-call drop ] keep ;
