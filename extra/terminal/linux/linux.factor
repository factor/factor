! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays classes.struct io.streams.c kernel
system terminal unix unix.ffi ;
QUALIFIED-WITH: alien.c-types c

IN: terminal.linux

<PRIVATE

CONSTANT: TIOCGWINSZ 0x5413

STRUCT: winsize
{ ws_row c:short }
{ ws_col c:short }
{ ws_xpixel c:short }
{ ws_ypixel c:short } ;

PRIVATE>

M: unix (terminal-size)
    stdout-handle fileno TIOCGWINSZ winsize <struct>
    [ ioctl ] keep swap 0 < [
        drop 0 0
    ] [
        [ ws_col>> ] [ ws_row>> ] bi
    ] if ;
