! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax kernel sequences system ;
IN: io.serial.unix.termios

CONSTANT: NCCS 20

TYPEDEF: uint tcflag_t
TYPEDEF: uchar cc_t
TYPEDEF: uint speed_t

C-STRUCT: termios
    { "tcflag_t" "iflag" }           !  input mode flags
    { "tcflag_t" "oflag" }           !  output mode flags
    { "tcflag_t" "cflag" }           !  control mode flags
    { "tcflag_t" "lflag" }           !  local mode flags
    { { "cc_t" NCCS } "cc" }         !  control characters
    { "speed_t" "ispeed" }           !  input speed
    { "speed_t" "ospeed" } ;         !  output speed
