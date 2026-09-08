! Copyright (C) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors arrays classes.struct io.streams.c kernel
math system terminal unix unix.ffi ;
QUALIFIED-WITH: alien.c-types c

IN: terminal.linux

<PRIVATE

CONSTANT: TIOCGWINSZ 0x5413

STRUCT: winsize
{ ws_row c:ushort }
{ ws_col c:ushort }
{ ws_xpixel c:ushort }
{ ws_ypixel c:ushort } ;

PRIVATE>

M: unix (terminal-size)
    stdout-handle fileno TIOCGWINSZ winsize new
    [ ioctl ] 1check 0 < [
        drop 0 0
    ] [
        [ ws_col>> ] [ ws_row>> ] bi
    ] if ;
