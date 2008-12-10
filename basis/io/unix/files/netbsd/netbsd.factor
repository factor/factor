! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax kernel unix.stat math unix
combinators system io.backend accessors alien.c-types
io.encodings.utf8 alien.strings unix.types io.unix.files
io.files unix.statvfs.netbsd unix.getfsstat.netbsd arrays
grouping sequences io.encodings.utf8 specialized-arrays.direct.uint ;
IN: io.unix.files.netbsd

TUPLE: netbsd-file-system-info < unix-file-system-info
blocks-reserved files-reserved
owner io-size sync-reads sync-writes async-reads async-writes
idx mount-from ;

M: netbsd new-file-system-info netbsd-file-system-info new ;

M: netbsd file-system-statvfs
    "statvfs" <c-object> tuck statvfs io-error ;

M: netbsd statvfs>file-system-info ( file-system-info statvfs -- file-system-info' )
    {
        [ statvfs-f_flag >>flags ]
        [ statvfs-f_bsize >>block-size ]
        [ statvfs-f_frsize >>preferred-block-size ]
        [ statvfs-f_iosize >>io-size ]
        [ statvfs-f_blocks >>blocks ]
        [ statvfs-f_bfree >>blocks-free ]
        [ statvfs-f_bavail >>blocks-available ]
        [ statvfs-f_bresvd >>blocks-reserved ]
        [ statvfs-f_files >>files ]
        [ statvfs-f_ffree >>files-free ]
        [ statvfs-f_favail >>files-available ]
        [ statvfs-f_fresvd >>files-reserved ]
        [ statvfs-f_syncreads >>sync-reads ]
        [ statvfs-f_syncwrites >>sync-writes ]
        [ statvfs-f_asyncreads >>async-reads ]
        [ statvfs-f_asyncwrites >>async-writes ]
        [ statvfs-f_fsidx 2 <direct-uint-array> >array >>idx ]
        [ statvfs-f_fsid >>id ]
        [ statvfs-f_namemax >>name-max ]
        [ statvfs-f_owner >>owner ]
        ! [ statvfs-f_spare >>spare ]
        [ statvfs-f_fstypename utf8 alien>string >>type ]
        [ statvfs-f_mntonname utf8 alien>string >>mount-point ]
        [ statvfs-f_mntfromname utf8 alien>string >>device-name ]
    } cleave ;

M: netbsd file-systems ( -- array )
    f 0 0 getvfsstat dup io-error
    "statvfs" <c-array> dup dup length 0 getvfsstat io-error
    "statvfs" heap-size group
    [ statvfs-f_mntonname utf8 alien>string file-system-info ] map ;
