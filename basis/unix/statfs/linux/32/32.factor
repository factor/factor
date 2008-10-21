! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types combinators kernel io.files unix.stat
math accessors system unix io.backend layouts vocabs.loader
alien.syntax ;
IN: unix.statfs.linux

C-STRUCT: statfs
    { "long"    "f_type" }
    { "long"    "f_bsize" }
    { "long"    "f_blocks" }
    { "long"    "f_bfree" }
    { "long"    "f_bavail" }
    { "long"    "f_files" }
    { "long"    "f_ffree" }
    { "fsid_t"  "f_fsid" }
    { "long"    "f_namelen" } ;

FUNCTION: int statfs ( char* path, statfs64* buf ) ;

TUPLE: linux32-file-system-info < file-system-info
type bsize blocks bfree bavail files ffree fsid
namelen frsize spare ;

M: linux >file-system-info ( struct -- statfs )
    [ \ linux32-file-system-info new ] dip
    {
        [
            [ statfs64-f_bsize ]
            [ statfs64-f_bavail ] bi * >>free-space
        ]
        [ statfs-f_type >>type ]
        [ statfs-f_bsize >>bsize ]
        [ statfs-f_blocks >>blocks ]
        [ statfs-f_bfree >>bfree ]
        [ statfs-f_bavail >>bavail ]
        [ statfs-f_files >>files ]
        [ statfs-f_ffree >>ffree ]
        [ statfs-f_fsid >>fsid ]
        [ statfs-f_namelen >>namelen ]
    } cleave ;

M: linux file-system-info ( path -- byte-array )
    normalize-path
    "statfs" <c-object> tuck statfs io-error
    >file-system-info ;
