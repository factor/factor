! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io.streams.plain
USING: generic assocs kernel math namespaces sequences
strings io.styles io io.streams.nested ;

TUPLE: plain-writer ;

: <plain-writer> ( stream -- new-stream )
    plain-writer construct-delegate ;

M: plain-writer stream-nl CHAR: \n swap stream-write1 ;

M: plain-writer stream-format
    highlight rot at [ >r >upper r> ] when stream-write ;

M: plain-writer with-nested-stream
    nip swap with-stream* ;

M: plain-writer with-stream-style
    (with-stream-style) ;
