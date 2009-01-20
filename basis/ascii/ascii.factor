! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.order sequences
combinators.short-circuit ;
IN: ascii

: ascii? ( ch -- ? ) 0 127 between? ; inline

: blank? ( ch -- ? ) " \t\n\r" member? ; inline

: letter? ( ch -- ? ) CHAR: a CHAR: z between? ; inline

: LETTER? ( ch -- ? ) CHAR: A CHAR: Z between? ; inline

: digit? ( ch -- ? ) CHAR: 0 CHAR: 9 between? ; inline

: printable? ( ch -- ? ) CHAR: \s CHAR: ~ between? ; inline

: control? ( ch -- ? )
    "\0\e\r\n\t\u000008\u00007f" member? ; inline

: quotable? ( ch -- ? )
    dup printable? [ "\"\\" member? not ] [ drop f ] if ; inline

: Letter? ( ch -- ? )
    [ [ letter? ] [ LETTER? ] ] 1|| ;

: alpha? ( ch -- ? )
    [ [ Letter? ] [ digit? ] ] 1|| ;

: ch>lower ( ch -- lower )
   dup CHAR: A CHAR: Z between? [ HEX: 20 + ] when ;

: >lower ( str -- lower )
   [ ch>lower ] map ;

: ch>upper ( ch -- upper )
    dup CHAR: a CHAR: z between? [ HEX: 20 - ] when ;

: >upper ( str -- upper )
    [ ch>upper ] map ;
