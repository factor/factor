! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: io.files.windows io.streams.duplex kernel math
math.bitwise windows windows.kernel32 windows.errors accessors
alien.c-types fry locals continuations classes.struct ;
IN: io.serial.windows

: <serial-stream> ( path encoding -- duplex )
    [ open-r/w dup ] dip <encoder-duplex> ;

: get-comm-state ( duplex -- dcb )
    in>> handle>>
    DCB new [ GetCommState win32-error=0/f ] keep ;

: set-comm-state ( duplex dcb -- )
    [ in>> handle>> ] dip
    SetCommState win32-error=0/f ;

:: with-comm-state ( duplex quot: ( dcb -- ) -- )
    duplex get-comm-state :> dcb
    dcb clone quot curry [ dcb set-comm-state ] recover ; inline
