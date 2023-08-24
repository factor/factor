! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel alien.syntax math io.files.unix system
unix.stat accessors combinators calendar.unix
io.files.info.unix ;
IN: io.files.info.unix.bsd

TUPLE: bsd-file-info < unix-file-info birth-time flags gen ;

M: bsd new-file-info bsd-file-info new ;

M: bsd stat>file-info
    [ call-next-method ] keep
    {
        [ st_flags>> >>flags ]
        [ st_gen>> >>gen ]
        [ st_birthtimespec>> timespec>unix-time >>birth-time ]
    } cleave ;
