! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: kernel-internals
USING: kernel math strings ;

: (sbuf>string) underlying dup rehash-string ;

IN: strings
USING: generic sequences ;

M: string resize resize-string ;

DEFER: sbuf?
BUILTIN: sbuf 13 sbuf?
    { 1 length set-capacity }
    { 2 underlying set-underlying } ;

M: sbuf set-length ( n sbuf -- ) grow-length ;

M: sbuf nth ( n sbuf -- ch ) bounds-check underlying char-slot ;

M: sbuf set-nth ( ch n sbuf -- )
    growable-check 2dup ensure underlying
    >r >r >fixnum r> r> set-char-slot ;

M: sbuf >string sbuf>string ;
