! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types assocs combinators destructors
kernel math math.bitwise math.parser sequences summary system
vocabs.loader ;
IN: serial

TUPLE: serial stream path baud 
    termios iflag oflag cflag lflag ;

ERROR: invalid-baud baud ;
M: invalid-baud summary ( invalid-baud -- string )
    "Baud rate "
    swap baud>> number>string
    " not supported" 3append ;

HOOK: lookup-baud os ( m -- n )
HOOK: open-serial os ( serial -- serial' )
M: serial dispose ( serial -- ) stream>> dispose ;

{
    { [ os unix? ] [ "serial.unix" ] } 
    { [ os windows? ] [ "serial.windows" ] }
} cond require
