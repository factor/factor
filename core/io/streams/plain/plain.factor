! Copyright (C) 2005, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel io ;
IN: io.streams.plain

MIXIN: plain-writer

M: plain-writer stream-nl
    CHAR: \n swap stream-write1 ;
