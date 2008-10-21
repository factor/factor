! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax accessors combinators kernel io.files ;
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

TUPLE: openbsd-file-system-info < file-system-info
bsize frsize blocks bfree bavail files ffree favail
fsid flag namemax ;

: statfs>file-system-info ( struct -- statfs )
    [ \ openbsd-file-system-info new ] dip
    {
        [
            [ statfs64-f_bsize ]
            [ statfs64-f_bavail ] bi * >>free-space
        ]
        [ statfs64-f_bsize >>bsize ]
        [ statfs64-f_frsize >>frsize ]
        [ statfs64-f_blocks >>blocks ]
        [ statfs64-f_bfree >>bfree ]
        [ statfs64-f_bavail >>bavail ]
        [ statfs64-f_files >>files ]
        [ statfs64-f_ffree >>ffree ]
        [ statfs64-f_favail >>favail ]
        [ statfs64-f_fsid >>fsid ]
        [ statfs64-f_flag >>flag ]
        [ statfs64-f_namelen >>namelen ]
    } cleave ;

M: openbsd file-system-info ( path -- byte-array )
    normalize-path
    "statvfs" <c-object> tuck statvfs io-error
    statfs>file-system-info ;
