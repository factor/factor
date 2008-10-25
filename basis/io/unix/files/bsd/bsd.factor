! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel alien.syntax math io.unix.files system
unix.stat accessors combinators calendar.unix ;
IN: io.unix.files.bsd

TUPLE: bsd-file-info < unix-file-info birth-time flags gen ;

M: bsd new-file-info ( -- class ) bsd-file-info new ;

M: bsd stat>file-info ( stat -- file-info )
    [ call-next-method ] keep
    {
        [ stat-st_flags >>flags ]
        [ stat-st_gen >>gen ]
        [
            stat-st_birthtimespec timespec>unix-time
            >>birth-time
        ]
    } cleave ;
