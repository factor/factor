! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators system vocabs ;
IN: io.serial.unix.termios

{
    { [ os linux? ] [ "io.serial.unix.termios.linux" ] }
    { [ os macosx? ] [ "io.serial.unix.termios.macosx" ] }
} cond require
