! Copyright (C) 2003, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: strings
USING: generic kernel kernel-internals math sequences
sequences-internals ;

M: string equal?
    over string? [
        over hashcode over hashcode number=
        [ sequence= ] [ 2drop f ] if
    ] [
        2drop f
    ] if ;

M: string hashcode
    dup string-hashcode [ ] [
        dup rehash-string string-hashcode
    ] ?if ;

M: string nth bounds-check nth-unsafe ;

M: string nth-unsafe >r >fixnum r> char-slot ;

M: string set-nth bounds-check set-nth-unsafe ;

M: string set-nth-unsafe 
    f over set-string-hashcode
    >r >fixnum >r >fixnum r> r> set-char-slot ;

M: string clone (clone) ;

M: string resize resize-string ;

! Characters
PREDICATE: integer blank " \t\n\r" member? ;
PREDICATE: integer letter CHAR: a CHAR: z between? ;
PREDICATE: integer LETTER CHAR: A CHAR: Z between? ;
PREDICATE: integer digit CHAR: 0 CHAR: 9 between? ;
PREDICATE: integer printable CHAR: \s CHAR: ~ between? ;
PREDICATE: integer control "\0\e\r\n\t\u0008\u007f" member? ;
PREDICATE: printable quotable "\"\\" member? not ;

UNION: Letter letter LETTER ;
UNION: alpha Letter digit ;

: ch>lower ( ch -- lower ) dup LETTER? [ HEX: 20 + ] when ;
: ch>upper ( ch -- lower ) dup letter? [ HEX: 20 - ] when ;
: >lower ( str -- lower ) [ ch>lower ] map ;
: >upper ( str -- upper ) [ ch>upper ] map ;

: padding ( str n ch -- padstr )
    >r swap length [-] r> <string> ;

: pad-left ( str n ch -- padded )
    pick >r padding r> append ;

: pad-right ( str n ch -- padded )
    pick >r padding r> swap append ;

: ch>string ( ch -- str ) 1 swap <string> ;

: >string ( seq -- str )
    [ string? ] [ 0 <string> ] >sequence ; inline

M: string thaw drop SBUF" " clone ;

M: string like drop dup string? [ >string ] unless ;
