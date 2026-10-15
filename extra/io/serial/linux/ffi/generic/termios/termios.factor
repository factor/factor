! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax classes.struct ;
IN: io.serial.linux.ffi

STRUCT: termios
    { iflag tcflag_t }
    { oflag tcflag_t }
    { cflag tcflag_t }
    { lflag tcflag_t }
    { line cc_t }
    { cc { cc_t NCCS } }
    { ispeed speed_t }
    { ospeed speed_t } ;
