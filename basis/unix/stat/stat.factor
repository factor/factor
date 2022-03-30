USING: accessors alien.c-types alien.syntax classes.struct
kernel sequences system unix vocabs ;
IN: unix.stat

! File Types

CONSTANT: S_IFMT   0o170000   ! These bits determine file type.

CONSTANT: S_IFDIR  0o040000   ! Directory.
CONSTANT: S_IFCHR  0o020000   ! Character device.
CONSTANT: S_IFBLK  0o060000   ! Block device.
CONSTANT: S_IFREG  0o100000   ! Regular file.
CONSTANT: S_IFIFO  0o010000   ! FIFO.
CONSTANT: S_IFLNK  0o120000   ! Symbolic link.
CONSTANT: S_IFSOCK 0o140000   ! Socket.
CONSTANT: S_IFWHT  0o160000   ! Whiteout.

STRUCT: fsid
    { __val int[2] } ;

TYPEDEF: fsid __fsid_t
TYPEDEF: fsid fsid_t

<< "unix.stat." os name>> append require >>

: file-status ( pathname -- stat )
    \ stat new [ [ stat-func ] unix-system-call drop ] keep ;

: link-status ( pathname -- stat )
    \ stat new [ [ lstat ] unix-system-call drop ] keep ;
