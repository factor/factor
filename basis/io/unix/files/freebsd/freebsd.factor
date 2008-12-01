! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.syntax combinators
io.backend io.files io.unix.files kernel math system unix
unix.statfs unix.statvfs.freebsd ;
IN: io.unix.files.freebsd

M: freebsd file-system-statvfs ( path -- byte-array )
    "statvfs" <c-object> tuck statvfs io-error ;

M: freebsd statvfs>file-system-info ( file-system-info statvfs -- file-system-info )
    {
        [ statvfs-f_bavail >>blocks-available ]
        [ statvfs-f_bfree >>blocks-free ]
        [ statvfs-f_blocks >>blocks ]
        [ statvfs-f_favail >>files-available ]
        [ statvfs-f_ffree >>files-free ]
        [ statvfs-f_files >>files ]
        [ statvfs-f_bsize >>block-size ]
        [ statvfs-f_flag >>flags ]
        [ statvfs-f_frsize >>preferred-block-size ]
        [ statvfs-f_fsid >>id ]
        [ statvfs-f_namemax >>name-max ]
    } cleave ;
