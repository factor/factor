! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel alien.syntax math io.unix.files system
unix.stat accessors combinators ;
IN: io.unix.files.macosx

TUPLE: macosx-file-info < unix-file-info flags gen ;

M: macosx new-file-info ( -- class ) macosx-file-info new ;

M: macosx stat>file-info ( stat -- file-info )
    [ call-next-method ] keep
    {
        [ stat-st_flags >>flags ]
        [ stat-st_gen >>gen ]
    } cleave ;
