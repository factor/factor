! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax kernel unix.stat math unix
combinators system io.backend accessors alien.c-types
io.encodings.utf8 alien.strings unix.types io.files.unix
io.files io.files.info unix.statvfs.netbsd unix.getfsstat.netbsd arrays
grouping sequences io.encodings.utf8 classes.struct
specialized-arrays io.files.info.unix ;
SPECIALIZED-ARRAY: statvfs
IN: io.files.info.unix.netbsd

TUPLE: netbsd-file-system-info < unix-file-system-info
blocks-reserved files-reserved
owner io-size sync-reads sync-writes async-reads async-writes
idx mount-from ;

M: netbsd new-file-system-info netbsd-file-system-info new ;

M: netbsd file-system-statvfs
    \ statvfs <struct> [ statvfs io-error ] keep ;

M: netbsd statvfs>file-system-info ( file-system-info statvfs -- file-system-info' )
    {
        [ f_flag>> >>flags ]
        [ f_bsize>> >>block-size ]
        [ f_frsize>> >>preferred-block-size ]
        [ f_iosize>> >>io-size ]
        [ f_blocks>> >>blocks ]
        [ f_bfree>> >>blocks-free ]
        [ f_bavail>> >>blocks-available ]
        [ f_bresvd>> >>blocks-reserved ]
        [ f_files>> >>files ]
        [ f_ffree>> >>files-free ]
        [ f_favail>> >>files-available ]
        [ f_fresvd>> >>files-reserved ]
        [ f_syncreads>> >>sync-reads ]
        [ f_syncwrites>> >>sync-writes ]
        [ f_asyncreads>> >>async-reads ]
        [ f_asyncwrites>> >>async-writes ]
        [ f_fsidx>> >>idx ]
        [ f_fsid>> >>id ]
        [ f_namemax>> >>name-max ]
        [ f_owner>> >>owner ]
        [ f_fstypename>> utf8 alien>string >>type ]
        [ f_mntonname>> utf8 alien>string >>mount-point ]
        [ f_mntfromname>> utf8 alien>string >>device-name ]
    } cleave ;

M: netbsd file-systems ( -- array )
    f 0 0 getvfsstat dup io-error
    <statvfs-array>
    [ dup byte-length 0 getvfsstat io-error ]
    [ [ f_mntonname>> utf8 alien>string file-system-info ] { } map-as ] bi ;
