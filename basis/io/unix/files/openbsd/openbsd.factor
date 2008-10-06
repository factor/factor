! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel alien.syntax math io.unix.files system
unix.stat accessors combinators calendar ;
IN: io.unix.files.openbsd

TUPLE: openbsd-file-info < unix-file-info birth-time flags gen ;

M: openbsd new-file-info ( -- class ) openbsd-file-info new ;

M: openbsd stat>file-info ( stat -- file-info )
    [ call-next-method ] keep
    {
        [ stat-st_flags >>flags ]
        [ stat-st_gen >>gen ]
        [ stat-st_birthtim timespec>timestamp >>birth-time ]
    } cleave ;
