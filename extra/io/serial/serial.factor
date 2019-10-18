! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors destructors io kernel math.parser sequences
summary system vocabs ;
IN: io.serial

TUPLE: serial-port < disposable stream path baud
    termios iflag oflag cflag lflag ;

ERROR: invalid-baud baud ;
M: invalid-baud summary ( invalid-baud -- string )
    baud>> number>string
    "Baud rate " " not supported" surround ;

HOOK: lookup-baud os ( m -- n )
HOOK: open-serial os ( serial -- serial' )
HOOK: default-serial-flags os ( m -- n )
M: serial-port dispose* ( serial -- ) stream>> dispose ;

: <serial-port> ( path baud -- obj )
    serial-port new
        swap >>baud
        swap >>path
        default-serial-flags ;

: with-duplex-stream ( duplex-stream quot -- )
    [ [ in>> ] [ out>> ] bi ] dip with-streams ; inline

: with-serial-port ( serial-port quot -- )
    [ open-serial ] dip with-duplex-stream ; inline

"io.serial." os name>> append require
