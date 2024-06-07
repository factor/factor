! Copyright (C) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors kernel math system terminal windows.kernel32 ;

IN: terminal.windows

M: windows (terminal-size)
    STD_OUTPUT_HANDLE GetStdHandle
    CONSOLE_SCREEN_BUFFER_INFO new
    [ GetConsoleScreenBufferInfo ] guard zero? [
        drop 0 0
    ] [
        srWindow>>
        [ [ Right>> ] [ Left>> ] bi - 1 + ]
        [ [ Bottom>> ] [ Top>> ] bi - 1 + ] bi
    ] if ;
