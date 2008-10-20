! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types combinators kernel ;
IN: unix.statfs.linux

TUPLE: linux-file-system-info < file-system-info
type bsize blocks bfree bavail files ffree fsid
namelen frsize spare ;

: statfs-struct>statfs ( struct -- statfs )
    [ \ statfs new ] dip
    {
        [ statfs64-f_type >>type ]
        [ statfs64-f_bsize >>bsize ]
        [ statfs64-f_blocks >>blocks ]
        [ statfs64-f_bfree >>bfree ]
        [ statfs64-f_bavail >>bavail ]
        [ statfs64-f_files >>files ]
        [ statfs64-f_ffree >>ffree ]
        [ statfs64-f_fsid >>fsid ]
        [ statfs64-f_namelen >>namelen ]
        [ statfs64-f_frsize >>frsize ]
        [ statfs64-f_spare >>spare ]
    } cleave ;

: statfs ( path -- byte-array )
    "statfs64" <c-object> [ statfs64 io-error ] keep ;

