! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax classes.struct kernel sequences system ;
IN: io.serial.unix.termios

CONSTANT: NCCS 20

TYPEDEF: uint tcflag_t
TYPEDEF: uchar cc_t
TYPEDEF: uint speed_t

STRUCT: termios
    { iflag tcflag_t }
    { oflag tcflag_t }
    { cflag tcflag_t }
    { lflag tcflag_t }
    { cc { cc_t NCCS } }
    { ispeed speed_t }
    { ospeed speed_t } ;
