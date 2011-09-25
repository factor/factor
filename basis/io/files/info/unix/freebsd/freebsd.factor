! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.syntax combinators
io.backend io.files io.files.info io.files.unix kernel math system unix
unix.statfs.freebsd unix.statvfs.freebsd unix.getfsstat.freebsd
sequences grouping alien.strings io.encodings.utf8 unix.types
arrays io.files.info.unix classes.struct specialized-arrays
alien.data ;
SPECIALIZED-ARRAY: statfs
IN: io.files.info.unix.freebsd

TUPLE: freebsd-file-system-info < unix-file-system-info
version io-size owner syncreads syncwrites asyncreads asyncwrites ;

M: freebsd new-file-system-info freebsd-file-system-info new ;

M: freebsd file-system-statfs ( path -- byte-array )
    \ statfs <struct> [ statfs io-error ] keep ;

M: freebsd statfs>file-system-info ( file-system-info statvfs -- file-system-info )
    {
        [ f_version>> >>version ]
        [ f_type>> >>type ]
        [ f_flags>> >>flags ]
        [ f_bsize>> >>block-size ]
        [ f_iosize>> >>io-size ]
        [ f_blocks>> >>blocks ]
        [ f_bfree>> >>blocks-free ]
        [ f_bavail>> >>blocks-available ]
        [ f_files>> >>files ]
        [ f_ffree>> >>files-free ]
        [ f_syncwrites>> >>syncwrites ]
        [ f_asyncwrites>> >>asyncwrites ]
        [ f_syncreads>> >>syncreads ]
        [ f_asyncreads>> >>asyncreads ]
        [ f_namemax>> >>name-max ]
        [ f_owner>> >>owner ]
        [ f_fsid>> >>id ]
        [ f_fstypename>> utf8 alien>string >>type ]
        [ f_mntfromname>> utf8 alien>string >>device-name ]
        [ f_mntonname>> utf8 alien>string >>mount-point ]
    } cleave ;

M: freebsd file-system-statvfs ( path -- byte-array )
    \ statvfs <struct> [ statvfs io-error ] keep ;

M: freebsd statvfs>file-system-info ( file-system-info statvfs -- file-system-info )
    {
        [ f_favail>> >>files-available ]
        [ f_frsize>> >>preferred-block-size ]
    } cleave ;

M: freebsd file-systems ( -- array )
    f 0 0 getfsstat dup io-error
    \ statfs <c-array>
    [ dup byte-length 0 getfsstat io-error ]
    [ [ f_mntonname>> utf8 alien>string file-system-info ] { } map-as ] bi ;
