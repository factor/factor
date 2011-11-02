! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators system vocabs ;
IN: io.serial.unix.termios

{
    { [ os linux? ] [ "io.serial.unix.termios.linux" ] }
    { [ os bsd? ] [ "io.serial.unix.termios.bsd" ] }
} cond require
