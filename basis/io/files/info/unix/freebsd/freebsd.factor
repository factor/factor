! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.strings arrays
calendar.unix classes.struct combinators grouping
io.encodings.utf8 io.files io.files.info io.files.info.unix
io.files.unix libc kernel math sequences specialized-arrays
system unix unix.getfsstat.freebsd unix.statfs.freebsd
unix.statvfs.freebsd ;
SPECIALIZED-ARRAY: uint
SPECIALIZED-ARRAY: statfs
IN: io.files.info.unix.freebsd

TUPLE: freebsd-file-info < unix-file-info birth-time flags gen ;

M: freebsd new-file-info freebsd-file-info new ;

M: freebsd stat>file-info
    [ call-next-method ] keep
    {
        [ st_flags>> >>flags ]
        [ st_gen>> >>gen ]
        [ st_birthtimespec>> timespec>unix-time >>birth-time ]
    } cleave ;

TUPLE: freebsd-file-system-info < unix-file-system-info
io-size owner type-id filesystem-subtype ;

M: freebsd file-systems
    f void* <ref> dup 0 getmntinfo dup io-error
    [ void* deref ] dip \ statfs <c-direct-array>
    [ f_mntonname>> utf8 alien>string file-system-info ] { } map-as ;

M: freebsd new-file-system-info freebsd-file-system-info new ;

M: freebsd file-system-statfs
    \ statfs new [ statfs-func io-error ] keep ;

M: freebsd file-system-statvfs
    \ statvfs new [ statvfs-func io-error ] keep ;

M: freebsd statfs>file-system-info
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
        [ f_fstypename>> utf8 alien>string >>type ]
        [ f_mntonname>> utf8 alien>string >>mount-point ]
        [ f_mntfromname>> utf8 alien>string >>device-name ]
    } cleave ;

M: freebsd statvfs>file-system-info
    {
        [ f_frsize>> >>preferred-block-size ]
        [ f_favail>> >>files-available ]
        [ f_namemax>> >>name-max ]
    } cleave ;
