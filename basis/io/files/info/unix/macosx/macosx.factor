! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.strings combinators
grouping io.encodings.utf8 io.files kernel math sequences system
unix io.files.unix arrays unix.statfs.macosx unix.statvfs.macosx
unix.getfsstat.macosx io.files.info.unix io.files.info
classes.struct specialized-arrays ;
SPECIALIZED-ARRAY: uint
SPECIALIZED-ARRAY: statfs64
IN: io.files.info.unix.macosx

TUPLE: macosx-file-system-info < unix-file-system-info
io-size owner type-id filesystem-subtype ;

M: macosx file-systems ( -- array )
    f <void*> dup 0 getmntinfo64 dup io-error
    [ *void* ] dip <direct-statfs64-array>
    [ f_mntonname>> utf8 alien>string file-system-info ] { } map-as ;

M: macosx new-file-system-info macosx-file-system-info new ;

M: macosx file-system-statfs ( normalized-path -- statfs )
    \ statfs64 <struct> [ statfs64 io-error ] keep ;

M: macosx file-system-statvfs ( normalized-path -- statvfs )
    \ statvfs <struct> [ statvfs io-error ] keep ;

M: macosx statfs>file-system-info ( file-system-info byte-array -- file-system-info' )
    {
        [ f_bsize>> >>block-size ]
        [ f_iosize>> >>io-size ]
        [ f_blocks>> >>blocks ]
        [ f_bfree>> >>blocks-free ]
        [ f_bavail>> >>blocks-available ]
        [ f_files>> >>files ]
        [ f_ffree>> >>files-free ]
        [ f_fsid>> >>id ]
        [ f_owner>> >>owner ]
        [ f_type>> >>type-id ]
        [ f_flags>> >>flags ]
        [ f_fssubtype>> >>filesystem-subtype ]
        [ f_fstypename>> utf8 alien>string >>type ]
        [ f_mntonname>> utf8 alien>string >>mount-point ]
        [ f_mntfromname>> utf8 alien>string >>device-name ]
    } cleave ;

M: macosx statvfs>file-system-info ( file-system-info byte-array -- file-system-info' )
    {
        [ f_frsize>> >>preferred-block-size ]
        [ f_favail>> >>files-available ]
        [ f_namemax>> >>name-max ]
    } cleave ;
