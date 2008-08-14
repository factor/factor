! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences system serial ;
IN: serial.unix

M: bsd lookup-baud ( m -- n )
    dup {
        0 50 75 110 134 150 200 300 600 1200 1800 2400 4800
        7200 9600 14400 19200 28800 38400 57600 76800 115200
        230400 460800 921600
    } member? [ invalid-baud ] unless ;
