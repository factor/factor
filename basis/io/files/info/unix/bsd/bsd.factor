! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel alien.syntax math io.files.unix system
unix.stat accessors combinators calendar.unix
io.files.info.unix ;
IN: io.files.info.unix.bsd

TUPLE: bsd-file-info < unix-file-info birth-time flags gen ;

M: bsd new-file-info bsd-file-info new ;

HOOK: stat>birth-time os ( stat -- birth-time )

! DragonFly's struct stat has no birth timestamp.
M: bsd stat>birth-time drop f ;

M: bsd stat>file-info
    [ call-next-method ] keep
    {
        [ st_flags>> >>flags ]
        [ st_gen>> >>gen ]
        [ stat>birth-time >>birth-time ]
    } cleave ;
