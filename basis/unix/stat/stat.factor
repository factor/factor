USING: kernel system combinators alien.syntax alien.c-types
math vocabs vocabs.loader unix classes.struct ;
IN: unix.stat

! File Types

CONSTANT: S_IFMT   0o170000   ! These bits determine file type.

CONSTANT: S_IFDIR  0o40000   ! Directory.
CONSTANT: S_IFCHR  0o20000   ! Character device.
CONSTANT: S_IFBLK  0o60000   ! Block device.
CONSTANT: S_IFREG  0o100000   ! Regular file.
CONSTANT: S_IFIFO  0o010000   ! FIFO.
CONSTANT: S_IFLNK  0o120000   ! Symbolic link.
CONSTANT: S_IFSOCK 0o140000   ! Socket.
CONSTANT: S_IFWHT  0o160000   ! Whiteout.

STRUCT: fsid
    { __val int[2] } ;

TYPEDEF: fsid __fsid_t
TYPEDEF: fsid fsid_t

<< os {
    { linux   [ "unix.stat.linux"   require ] }
    { macosx  [ "unix.stat.macosx"  require ] }
} case >>

: file-status ( pathname -- stat )
    \ stat <struct> [ [ stat-func ] unix-system-call drop ] keep ;

: link-status ( pathname -- stat )
    \ stat <struct> [ [ lstat ] unix-system-call drop ] keep ;
