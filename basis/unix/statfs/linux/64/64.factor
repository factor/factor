! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types combinators kernel io.files unix.stat
math accessors system unix io.backend layouts vocabs.loader
alien.syntax ;
IN: unix.statfs.linux

C-STRUCT: statfs64
    { "__SWORD_TYPE" "f_type" }
    { "__SWORD_TYPE" "f_bsize" }
    { "__fsblkcnt64_t" "f_blocks" }
    { "__fsblkcnt64_t" "f_bfree" }
    { "__fsblkcnt64_t" "f_bavail" }
    { "__fsfilcnt64_t" "f_files" }
    { "__fsfilcnt64_t" "f_ffree" }
    { "__fsid_t" "f_fsid" }
    { "__SWORD_TYPE" "f_namelen" }
    { "__SWORD_TYPE" "f_frsize" }
    { { "__SWORD_TYPE" 5 } "f_spare" } ;

FUNCTION: int statfs64 ( char* path, statfs64* buf ) ;

TUPLE: linux64-file-system-info < file-system-info
type bsize blocks bfree bavail files ffree fsid
namelen frsize spare ;

M: linux >file-system-info ( struct -- statfs )
    [ \ linux64-file-system-info new ] dip
    {
        [
            [ statfs64-f_bsize ]
            [ statfs64-f_bavail ] bi * >>free-space
        ]
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

M: linux file-system-info ( path -- byte-array )
    normalize-path
    "statfs64" <c-object> tuck statfs64 io-error
    >file-system-info ;
