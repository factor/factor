! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax kernel system unix ;
IN: io.serial.unix.termios

CONSTANT: NCCS 32

TYPEDEF: uchar cc_t
TYPEDEF: uint speed_t
TYPEDEF: uint tcflag_t

C-STRUCT: termios
    { "tcflag_t" "iflag" }           !  input mode flags
    { "tcflag_t" "oflag" }           !  output mode flags
    { "tcflag_t" "cflag" }           !  control mode flags
    { "tcflag_t" "lflag" }           !  local mode flags
    { "cc_t" "line" }                !  line discipline
    { { "cc_t" NCCS } "cc" }         !  control characters
    { "speed_t" "ispeed" }           !  input speed
    { "speed_t" "ospeed" } ;         !  output speed
