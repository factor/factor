! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax classes.struct kernel system unix ;
IN: io.serial.unix.termios

CONSTANT: NCCS 32

TYPEDEF: uchar cc_t
TYPEDEF: uint speed_t
TYPEDEF: uint tcflag_t

STRUCT: termios
    { iflag tcflag_t }
    { oflag tcflag_t }
    { cflag tcflag_t }
    { lflag tcflag_t }
    { line cc_t }
    { cc { cc_t NCCS } }
    { ispeed speed_t }
    { ospeed speed_t } ;
