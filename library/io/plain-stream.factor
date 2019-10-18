! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io
USING: generic hashtables kernel math namespaces sequences
strings styles ;

TUPLE: plain-writer ;

C: plain-writer ( stream -- stream ) [ set-delegate ] keep ;

M: plain-writer stream-terpri CHAR: \n swap stream-write1 ;

M: plain-writer stream-format
    highlight rot hash [ >r >upper r> ] when stream-write ;

M: plain-writer with-nested-stream
    nip swap with-stream* ;

M: plain-writer with-stream-style
    (with-stream-style) ;
