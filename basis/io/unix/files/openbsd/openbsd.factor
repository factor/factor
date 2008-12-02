! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax accessors combinators kernel
unix.types math system io.backend alien.c-types unix
io.files io.unix.files unix.statvfs.openbsd ;
IN: io.unix.files.openbsd

M: openbsd file-system-statfs
    "statfs" <c-object> tuck statfs io-error ;

M: openbsd statfs>file-system-info ( file-system-info statfs -- file-system-info' )
    {
        [ statfs-f_flag >>flags ]
        [ statfs-f_bsize >>block-size ]
        [ statfs-f_iosize >>io-size ]
        [ statfs-f_blocks >>blocks ]
        [ statfs-f_bfree >>blocks-free ]
        [ statfs-f_bavail >>blocks-available ]
        [ statfs-f_files >>files ]
        [ statfs-f_ffree >>files-free ]
        [ statfs-f_favail >>files-available ]
        [ statfs-f_syncwrites >>sync-writes ]
        [ statfs-f_syncreads >>sync-reads ]
        [ statfs-f_asyncwrites >>async-writes ]
        [ statfs-f_asyncreads >>async-reads ]
        [ statfs-f_fsid >>id ]
        [ statfs-f_namemax >>name-max ]
        [ statfs-f_owner >>owner ]
        [ statfs-f_spare >>spare ]
        [ statfs-f_fstypename alien>native-string >>type ]
        [ statfs-f_mntonname alien>native-string >>mount-point ]
        [ statfs-f_mntfromname alien>native-string >>device-name ]
    } cleave ;

M: openbsd file-system-statvfs ( normalized-path -- statvfs )
    "statvfs" <c-object> tuck statvfs io-error ;

M: openbsd statvfs>file-system-info ( file-system-info statvfs -- file-system-info' )
    {
        [ statvfs-f_frsize >>preferred-block-size ]
    } cleave ;
