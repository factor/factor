! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax accessors combinators kernel
unix.types math system io.backend alien.c-types unix
unix.statfs io.files io.unix.files unix.statvfs.openbsd ;
IN: io.unix.files.openbsd

M: openbsd file-system-statvfs ( normalized-path -- statvfs )
    "statvfs" <c-object> tuck statvfs io-error ;

M: openbsd statvfs>file-system-info ( file-system-info statvfs -- file-system-info' )
    {
        [ statvfs-f_bsize >>block-size ]
        [ statvfs-f_frsize >>preferred-block-size ]
        [ statvfs-f_blocks >>blocks ]
        [ statvfs-f_bfree >>blocks-free ]
        [ statvfs-f_bavail >>blocks-available ]
        [ statvfs-f_files >>files ]
        [ statvfs-f_ffree >>files-free ]
        [ statvfs-f_favail >>files-available ]
        [ statvfs-f_fsid >>id ]
        [ statvfs-f_flag >>flags ]
        [ statvfs-f_namemax >>name-max ]
    } cleave ;
