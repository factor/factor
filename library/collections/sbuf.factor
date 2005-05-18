! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: strings
USING: generic kernel kernel-internals math math-internals
sequences ;

M: string (grow) grow-string ;

DEFER: sbuf?
BUILTIN: sbuf 13 sbuf?
    [ 1 length set-capacity ]
    [ 2 underlying set-underlying ] ;

M: sbuf set-length ( n sbuf -- )
    growable-check 2dup grow set-capacity ;

M: sbuf nth ( n sbuf -- ch )
    bounds-check underlying char-slot ;

M: sbuf set-nth ( ch n sbuf -- )
    growable-check 2dup ensure underlying
    >r >r >fixnum r> r> set-char-slot ;

M: sbuf >string sbuf>string ;
