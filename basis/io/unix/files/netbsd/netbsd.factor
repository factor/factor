! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel alien.syntax math io.unix.files system
unix.stat accessors combinators calendar.unix ;
IN: io.unix.files.netbsd

TUPLE: netbsd-file-info < unix-file-info birth-time flags gen ;

M: netbsd new-file-info ( -- class ) netbsd-file-info new ;

M: netbsd stat>file-info ( stat -- file-info )
    [ call-next-method ] keep
    {
        [ stat-st_flags >>flags ]
        [ stat-st_gen >>gen ]
        [ stat-st_birthtim timespec>timestamp >>birth-time ]
    } cleave ;
