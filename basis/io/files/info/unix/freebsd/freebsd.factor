! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.syntax combinators
io.backend io.files io.files.info io.files.unix kernel math system unix
unix.statfs.freebsd unix.statvfs.freebsd unix.getfsstat.freebsd
sequences grouping alien.strings io.encodings.utf8 unix.types
specialized-arrays.direct.uint arrays io.files.info.unix ;
IN: io.files.info.unix.freebsd

TUPLE: freebsd-file-system-info < unix-file-system-info
version io-size owner syncreads syncwrites asyncreads asyncwrites ;

M: freebsd new-file-system-info freebsd-file-system-info new ;

M: freebsd file-system-statfs ( path -- byte-array )
    "statfs" <c-object> [ statfs io-error ] keep ;

M: freebsd statfs>file-system-info ( file-system-info statvfs -- file-system-info )
    {
        [ statfs-f_version >>version ]
        [ statfs-f_type >>type ]
        [ statfs-f_flags >>flags ]
        [ statfs-f_bsize >>block-size ]
        [ statfs-f_iosize >>io-size ]
        [ statfs-f_blocks >>blocks ]
        [ statfs-f_bfree >>blocks-free ]
        [ statfs-f_bavail >>blocks-available ]
        [ statfs-f_files >>files ]
        [ statfs-f_ffree >>files-free ]
        [ statfs-f_syncwrites >>syncwrites ]
        [ statfs-f_asyncwrites >>asyncwrites ]
        [ statfs-f_syncreads >>syncreads ]
        [ statfs-f_asyncreads >>asyncreads ]
        [ statfs-f_namemax >>name-max ]
        [ statfs-f_owner >>owner ]
        [ statfs-f_fsid 2 <direct-uint-array> >array >>id ]
        [ statfs-f_fstypename utf8 alien>string >>type ]
        [ statfs-f_mntfromname utf8 alien>string >>device-name ]
        [ statfs-f_mntonname utf8 alien>string >>mount-point ]
    } cleave ;

M: freebsd file-system-statvfs ( path -- byte-array )
    "statvfs" <c-object> [ statvfs io-error ] keep ;

M: freebsd statvfs>file-system-info ( file-system-info statvfs -- file-system-info )
    {
        [ statvfs-f_favail >>files-available ]
        [ statvfs-f_frsize >>preferred-block-size ]
    } cleave ;

M: freebsd file-systems ( -- array )
    f 0 0 getfsstat dup io-error
    "statfs" <c-array> dup dup length 0 getfsstat io-error
    "statfs" heap-size group
    [ statfs-f_mntonname alien>native-string file-system-info ] map ;
