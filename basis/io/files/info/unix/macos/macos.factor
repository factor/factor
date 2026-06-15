! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.strings arrays
calendar.unix classes.struct combinators grouping
io.encodings.utf8 io.files io.files.info io.files.info.unix
io.files.unix libc kernel math sequences specialized-arrays
system unix unix.getfsstat.macos unix.statfs.macos
unix.statvfs.macos ;
FROM: unix.getfsstat.macos => MNT_NOWAIT ;
SPECIALIZED-ARRAY: uint
SPECIALIZED-ARRAY: statfs64
IN: io.files.info.unix.macos

TUPLE: macos-file-info < unix-file-info birth-time flags gen ;

M: macos new-file-info macos-file-info new ;

M: macos stat>file-info
    [ call-next-method ] keep
    {
        [ st_flags>> >>flags ]
        [ st_gen>> >>gen ]
        [ st_birthtimespec>> timespec>unix-time >>birth-time ]
    } cleave ;

TUPLE: macos-file-system-info < unix-file-system-info
io-size owner type-id filesystem-subtype ;

: statfs>file-systems-info ( statfs -- file-system-info )
    [ new-file-system-info ] dip statfs>file-system-info
    file-system-calculations ;

: (file-systems) ( -- statfs64-array )
    f 0 MNT_NOWAIT getfsstat64 dup io-error statfs64 <c-array>
    [ dup length statfs64 heap-size * MNT_NOWAIT getfsstat64 dup io-error ] keep
    swap index-or-length head ;

M: macos file-systems
    (file-systems) [ statfs>file-systems-info ] { } map-as ;

M: macos new-file-system-info macos-file-system-info new ;

M: macos file-system-statfs
    \ statfs64 new [ statfs64-func io-error ] keep ;

M: macos file-system-statvfs
    \ statvfs new [ statvfs-func io-error ] keep ;

M: macos statfs>file-system-info
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

M: macos statvfs>file-system-info
    {
        [ f_frsize>> >>preferred-block-size ]
        [ f_favail>> >>files-available ]
        [ f_namemax>> >>name-max ]
    } cleave ;
