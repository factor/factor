! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: kernel-internals
USING: kernel math strings sequences-internals ;

: (sbuf>string) underlying dup rehash-string ;

IN: strings
USING: generic sequences ;

M: string resize resize-string ;

M: sbuf set-length ( n sbuf -- ) grow-length ;

M: sbuf nth-unsafe underlying >r >fixnum r> char-slot ;

M: sbuf nth ( n sbuf -- ch ) bounds-check nth-unsafe ;

M: sbuf set-nth-unsafe ( ch n sbuf -- )
    underlying >r >fixnum >r >fixnum r> r> set-char-slot ;

M: sbuf set-nth ( ch n sbuf -- )
    growable-check 2dup ensure set-nth-unsafe ;

M: sbuf >string sbuf>string ;

M: sbuf clone clone-growable ;
