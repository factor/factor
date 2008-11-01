! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax accessors combinators kernel
unix.types math system io.backend alien.c-types unix
unix.statfs io.files ;
IN: unix.statfs.openbsd

C-STRUCT: statvfs
    { "ulong" "f_bsize" }
    { "ulong" "f_frsize" }
    { "fsblkcnt_t" "f_blocks" }
    { "fsblkcnt_t" "f_bfree" }
    { "fsblkcnt_t" "f_bavail" }
    { "fsfilcnt_t" "f_files" }
    { "fsfilcnt_t" "f_ffree" }
    { "fsfilcnt_t" "f_favail" }
    { "ulong" "f_fsid" }
    { "ulong" "f_flag" }
    { "ulong" "f_namemax" } ;

: ST_RDONLY       1 ; inline
: ST_NOSUID       2 ; inline

FUNCTION: int statvfs ( char* path, statvfs* buf ) ;

TUPLE: openbsd-file-system-info < file-system-info
bsize frsize blocks bfree bavail files ffree favail
fsid flag namemax ;

M: openbsd >file-system-info ( struct -- statfs )
    [ \ openbsd-file-system-info new ] dip
    {
        [
            [ statvfs-f_bsize ]
            [ statvfs-f_bavail ] bi * >>free-space
        ]
        [ statvfs-f_bsize >>bsize ]
        [ statvfs-f_frsize >>frsize ]
        [ statvfs-f_blocks >>blocks ]
        [ statvfs-f_bfree >>bfree ]
        [ statvfs-f_bavail >>bavail ]
        [ statvfs-f_files >>files ]
        [ statvfs-f_ffree >>ffree ]
        [ statvfs-f_favail >>favail ]
        [ statvfs-f_fsid >>fsid ]
        [ statvfs-f_flag >>flag ]
        [ statvfs-f_namemax >>namemax ]
    } cleave ;

M: openbsd file-system-info ( path -- byte-array )
    normalize-path
    "statvfs" <c-object> tuck statvfs io-error
    >file-system-info ;
