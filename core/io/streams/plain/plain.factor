! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel io io.streams.nested ;
IN: io.streams.plain

MIXIN: plain-writer

M: plain-writer stream-nl
    CHAR: \n swap stream-write1 ;

M: plain-writer stream-format
    nip stream-write ;

M: plain-writer make-span-stream
    swap <style-stream> <ignore-close-stream> ;

M: plain-writer make-block-stream
    nip <ignore-close-stream> ;
