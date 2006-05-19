! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: strings
USING: generic kernel kernel-internals math sequences
sequences-internals ;

M: string = ( obj str -- ? )
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

M: string nth bounds-check char-slot ;

M: string nth-unsafe >r >fixnum r> char-slot ;

M: string set-nth bounds-check set-nth-unsafe ;

M: string set-nth-unsafe 
    f over set-string-hashcode
    >r >fixnum >r >fixnum r> r> set-char-slot ;

M: string clone (clone) ;

M: string resize resize-string ;

! Characters
PREDICATE: integer blank     " \t\n\r" member? ;
PREDICATE: integer letter    CHAR: a CHAR: z between? ;
PREDICATE: integer LETTER    CHAR: A CHAR: Z between? ;
PREDICATE: integer digit     CHAR: 0 CHAR: 9 between? ;
PREDICATE: integer printable CHAR: \s CHAR: ~ between? ;
PREDICATE: integer control   "\0\e\r\n\t\u0008\u007f" member? ;

: ch>lower ( n -- n ) dup LETTER? [ HEX: 20 + ] when ;
: ch>upper ( n -- n ) dup letter? [ HEX: 20 - ] when ;
: >lower ( str -- str ) [ ch>lower ] map ;
: >upper ( str -- str ) [ ch>upper ] map ;

: quotable? ( ch -- ? )
    #! In a string literal, can this character be used without
    #! escaping?
    dup printable? swap "\"\\" member? not and ; foldable

: padding ( string count char -- string )
    >r swap length - 0 max r> <string> ; flushable

: pad-left ( string count char -- string )
    pick >r padding r> append ; flushable

: pad-right ( string count char -- string )
    pick >r padding r> swap append ; flushable

: ch>string ( ch -- str ) 1 swap <string> ; flushable

: >string ( seq -- array ) [ 0 <string> ] >sequence ; inline

M: string thaw drop SBUF" " clone ;

M: string like ( seq sbuf -- string )
    drop dup string? [ >string ] unless ;
