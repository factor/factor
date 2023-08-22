! Copyright (C) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors alien.c-types classes.struct io.streams.c
kernel math memoize scratchpad system terminal unix unix.ffi ;

QUALIFIED-WITH: alien.c-types c

IN: terminal.macosx

<PRIVATE

CONSTANT: IOCPARM_MASK 0x1fff ! parameter length, at most 13 bits
CONSTANT: IOC_VOID 0x20000000 ! no parameters
CONSTANT: IOC_OUT  0x40000000 ! copy parameters out
CONSTANT: IOC_IN   0x80000000 ! copy parameters in

: _IOC ( inout group num len -- n )
    [ 8 shift ] 2dip IOCPARM_MASK bitand 16 shift
    bitor bitor bitor ;

: _IO ( group num -- n ) [ IOC_VOID ] 2dip 0 _IOC ;

: _IOCR ( group num len -- n ) [ IOC_OUT ] 3dip _IOC ;

: _IOCW ( group num len -- n ) [ IOC_IN ] 3dip _IOC ;

STRUCT: winsize
{ ws_row c:short }
{ ws_col c:short }
{ ws_xpixel c:short }
{ ws_ypixel c:short } ;

MEMO: TIOCGWINSZ ( -- x ) CHAR: t 104 winsize heap-size _IOCR ;

PRIVATE>

M: macosx (terminal-size)
    stdout-handle fileno TIOCGWINSZ winsize new
    [ ioctl ] keep swap 0 < [
        drop 0 0
    ] [
        [ ws_col>> ] [ ws_row>> ] bi
    ] if ;
