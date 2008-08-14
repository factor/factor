! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax kernel sequences system serial ;
IN: serial.unix

M: bsd lookup-baud ( m -- n )
    dup {
        0 50 75 110 134 150 200 300 600 1200 1800 2400 4800
        7200 9600 14400 19200 28800 38400 57600 76800 115200
        230400 460800 921600
    } member? [ invalid-baud ] unless ;

: TCSANOW     0 ; inline
: TCSADRAIN   1 ; inline
: TCSAFLUSH   2 ; inline
: TCSASOFT    HEX: 10 ; inline

: TCIFLUSH    1 ; inline
: TCOFLUSH    2 ; inline
: TCIOFLUSH   3 ; inline
: TCOOFF      1 ; inline
: TCOON       2 ; inline
: TCIOFF      3 ; inline
: TCION       4 ; inline
