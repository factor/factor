! Copyright (C) 2003, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math.private sequences kernel.private
math sequences.private slots.private ;
IN: strings

<PRIVATE

: string-hashcode 2 slot ; inline

: set-string-hashcode 2 set-slot ; inline

: reset-string-hashcode f swap set-string-hashcode ; inline

: rehash-string ( str -- )
    1 over sequence-hashcode swap set-string-hashcode ; inline

PRIVATE>

M: string equal?
    over string? [
        over hashcode over hashcode number=
        [ sequence= ] [ 2drop f ] if
    ] [
        2drop f
    ] if ;

M: string hashcode*
    nip dup string-hashcode [ ]
    [ dup rehash-string string-hashcode ] ?if ;

M: string nth-unsafe >r >fixnum r> char-slot ;

M: string set-nth-unsafe 
    dup reset-string-hashcode
    >r >fixnum >r >fixnum r> r> set-char-slot ;

M: string clone (clone) ;

M: string resize resize-string ;

! Characters
: blank? ( ch -- ? ) " \t\n\r" member? ; inline
: letter? ( ch -- ? ) CHAR: a CHAR: z between? ; inline
: LETTER? ( ch -- ? ) CHAR: A CHAR: Z between? ; inline
: digit? ( ch -- ? ) CHAR: 0 CHAR: 9 between? ; inline
: printable? ( ch -- ? ) CHAR: \s CHAR: ~ between? ; inline
: control? ( ch -- ? ) "\0\e\r\n\t\u0008\u007f" member? ; inline

: quotable? ( ch -- ? )
    dup printable? [ "\"\\" member? not ] [ drop f ] if ; inline

: Letter? ( ch -- ? )
    dup letter? [ drop t ] [ LETTER? ] if ; inline

: alpha? ( ch -- ? )
    dup Letter? [ drop t ] [ digit? ] if ; inline

: ch>lower ( ch -- lower )
    dup LETTER? [ HEX: 20 + ] when ; inline

: ch>upper ( ch -- upper )
    dup letter? [ HEX: 20 - ] when ; inline

: >lower ( str -- lower ) [ ch>lower ] map ;

: >upper ( str -- upper ) [ ch>upper ] map ;

: 1string ( ch -- str ) 1 swap <string> ;

: >string ( seq -- str ) "" clone-like ;

M: string new drop 0 <string> ;

INSTANCE: string sequence
