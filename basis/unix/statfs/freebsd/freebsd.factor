! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax kernel unix io.files math accessors
combinators system io.backend alien.c-types ;
IN: unix.statfs.freebsd

: ST_RDONLY       1 ; inline
: ST_NOSUID       2 ; inline

C-STRUCT: statvfs               
    { "fsblkcnt_t" "f_bavail" }
    { "fsblkcnt_t" "f_bfree" }
    { "fsblkcnt_t" "f_blocks" }
    { "fsfilcnt_t" "f_favail" }
    { "fsfilcnt_t" "f_ffree" }
    { "fsfilcnt_t" "f_files" }
    { "ulong" "f_bsize" }
    { "ulong" "f_flag" }
    { "ulong" "f_frsize" }
    { "ulong" "f_fsid" }
    { "ulong" "f_namemax" } ;

FUNCTION: int statvfs ( char* path, statvfs* buf ) ;

TUPLE: freebsd-file-system-info < file-system-info
bavail bfree blocks favail ffree ffiles
bsize flag frsize fsid namemax ;

M: freebsd >file-system-info ( struct -- statfs )
    [ \ freebsd-file-system-info new ] dip
    {
        [
            [ statvfs-f_bsize ]
            [ statvfs-f_bavail ] bi * >>free-space
        ]
        [ statvfs-f_bavail >>bavail ]
        [ statvfs-f_bfree >>bfree ]
        [ statvfs-f_blocks >>blocks ]
        [ statvfs-f_favail >>favail ]
        [ statvfs-f_ffree >>ffree ]
        [ statvfs-f_files >>files ]
        [ statvfs-f_bsize >>bsize ]
        [ statvfs-f_flag >>flag ]
        [ statvfs-f_frsize >>frsize ]
        [ statvfs-f_fsid >>fsid ]
        [ statvfs-f_namemax >>namemax ]
    } cleave ;

M: freebsd file-system-info ( path -- byte-array )
    normalize-path
    "statvfs" <c-object> tuck statvfs io-error
    >file-system-info ;
