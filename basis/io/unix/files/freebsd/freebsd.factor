! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel alien.syntax math io.unix.files system
unix.stat accessors combinators calendar.unix ;
IN: io.unix.files.freebsd

TUPLE: freebsd-file-info < unix-file-info birth-time flags gen ;

M: freebsd new-file-info ( -- class ) freebsd-file-info new ;

M: freebsd stat>file-info ( stat -- file-info )
    [ call-next-method ] keep
    {
        [ stat-st_flags >>flags ]
        [ stat-st_gen >>gen ]
        [ stat-st_birthtimespec timespec>timestamp >>birth-time ]
    } cleave ;
