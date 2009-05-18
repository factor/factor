USING: kernel system combinators alien.syntax alien.c-types
math io.backend.unix vocabs.loader unix ;
IN: unix.stat

! File Types

CONSTANT: S_IFMT   OCT: 170000   ! These bits determine file type.

CONSTANT: S_IFDIR  OCT:  40000   ! Directory.
CONSTANT: S_IFCHR  OCT:  20000   ! Character device.
CONSTANT: S_IFBLK  OCT:  60000   ! Block device.
CONSTANT: S_IFREG  OCT: 100000   ! Regular file.
CONSTANT: S_IFIFO  OCT: 010000   ! FIFO.
CONSTANT: S_IFLNK  OCT: 120000   ! Symbolic link.
CONSTANT: S_IFSOCK OCT: 140000   ! Socket.
CONSTANT: S_IFWHT  OCT: 160000   ! Whiteout.

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
