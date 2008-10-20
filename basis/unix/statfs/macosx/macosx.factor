! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types io.encodings.utf8 io.encodings.string
kernel sequences unix.stat accessors unix combinators math
grouping system unix.statfs io.files io.backend alien.strings ;
IN: unix.statfs.macosx

TUPLE: macosx-file-system-info < file-system-info
block-size io-size blocks blocks-free blocks-available files
files-free file-system-id owner type flags filesystem-subtype
file-system-type-name mount-from ;

M: macosx mounted* ( -- array )
    f <void*> dup 0 getmntinfo64 dup io-error
    [ *void* ] dip
    "statfs64" heap-size [ * memory>byte-array ] keep group ;

: statfs64>file-system-info ( byte-array -- file-system-info )
    [ \ macosx-file-system-info new ] dip
    {
        [
            [ statfs64-f_bavail ] [ statfs64-f_bsize ] bi *
            >>free-space
        ]
        [ statfs64-f_mntonname utf8 alien>string >>mount-on ]
        [ statfs64-f_bsize >>block-size ]

        [ statfs64-f_iosize >>io-size ]
        [ statfs64-f_blocks >>blocks ]
        [ statfs64-f_bfree >>blocks-free ]
        [ statfs64-f_bavail >>blocks-available ]
        [ statfs64-f_files >>files ]
        [ statfs64-f_ffree >>files-free ]
        [ statfs64-f_fsid >>file-system-id ]
        [ statfs64-f_owner >>owner ]
        [ statfs64-f_type >>type ]
        [ statfs64-f_flags >>flags ]
        [ statfs64-f_fssubtype >>filesystem-subtype ]
        [
            statfs64-f_fstypename utf8 alien>string
            >>file-system-type-name
        ]
        [
            statfs64-f_mntfromname
            utf8 alien>string >>mount-from
        ]
    } cleave ;

M: macosx file-system-info ( path -- file-system-info )
    normalize-path
    "statfs64" <c-object> tuck statfs64 io-error
    statfs64>file-system-info ;
