! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io.streams.plain
USING: generic assocs kernel math namespaces sequences
io.styles io io.streams.nested ;

TUPLE: plain-writer ;

: <plain-writer> ( stream -- new-stream )
    plain-writer construct-delegate ;

M: plain-writer stream-nl
    CHAR: \n swap stream-write1 ;

M: plain-writer stream-format
    nip stream-write ;

M: plain-writer make-span-stream
    <style-stream> <ignore-close-stream> ;

M: plain-writer make-block-stream
    nip <ignore-close-stream> ;
