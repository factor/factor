! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.strings combinators
grouping io.encodings.utf8 io.files kernel math sequences
system unix io.unix.files
unix.statfs.macosx unix.statvfs.macosx unix.getfsstat.macosx ;
IN: io.unix.files.macosx

TUPLE: macosx-file-system-info < unix-file-system-info
io-size owner type-id filesystem-subtype ;

M: macosx file-systems ( -- array )
    f 0 0 getfsstat64 dup io-error
    "statfs" <c-array> dup dup length 0 getfsstat64 io-error
    "statfs" heap-size group
    [ statfs64-f_mntonname alien>native-string file-system-info ] map ;

M: macosx new-file-system-info macosx-file-system-info new ;

M: macosx file-system-statfs ( normalized-path -- statfs )
    "statfs64" <c-object> tuck statfs64 io-error ;

M: macosx file-system-statvfs ( normalized-path -- statvfs )
    "statvfs" <c-object> tuck statvfs io-error ;

M: macosx statfs>file-system-info ( file-system-info byte-array -- file-system-info' )
    {
        [ statfs64-f_bsize >>block-size ]
        [ statfs64-f_iosize >>io-size ]
        [ statfs64-f_blocks >>blocks ]
        [ statfs64-f_bfree >>blocks-free ]
        [ statfs64-f_bavail >>blocks-available ]
        [ statfs64-f_files >>files ]
        [ statfs64-f_ffree >>files-free ]
        [ statfs64-f_fsid >>id ]
        [ statfs64-f_owner >>owner ]
        [ statfs64-f_type >>type-id ]
        [ statfs64-f_flags >>flags ]
        [ statfs64-f_fssubtype >>filesystem-subtype ]
        [ statfs64-f_fstypename utf8 alien>string >>type ]
        [ statfs64-f_mntonname utf8 alien>string >>mount-point ]
        [ statfs64-f_mntfromname utf8 alien>string >>device-name ]
    } cleave ;

M: macosx statvfs>file-system-info ( file-system-info byte-array -- file-system-info' )
    {
        [ statvfs-f_frsize >>preferred-block-size ]
        [ statvfs-f_favail >>files-available ]
        [ statvfs-f_namemax >>name-max ]
    } cleave ;
