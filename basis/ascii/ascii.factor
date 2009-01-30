! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.order sequences strings
combinators.short-circuit hints ;
IN: ascii

: ascii? ( ch -- ? ) 0 127 between? ; inline
: blank? ( ch -- ? ) " \t\n\r" member? ; inline
: letter? ( ch -- ? ) CHAR: a CHAR: z between? ; inline
: LETTER? ( ch -- ? ) CHAR: A CHAR: Z between? ; inline
: digit? ( ch -- ? ) CHAR: 0 CHAR: 9 between? ; inline
: printable? ( ch -- ? ) CHAR: \s CHAR: ~ between? ; inline
: control? ( ch -- ? ) "\0\e\r\n\t\u000008\u00007f" member? ; inline
: quotable? ( ch -- ? ) { [ printable? ] [ "\"\\" member? not ] } 1&& ; inline
: Letter? ( ch -- ? ) { [ letter? ] [ LETTER? ] } 1|| ; inline
: alpha? ( ch -- ? ) { [ Letter? ] [ digit? ] } 1|| ; inline
: ch>lower ( ch -- lower ) dup LETTER? [ HEX: 20 + ] when ; inline
: >lower ( str -- lower ) [ ch>lower ] map ;
: ch>upper ( ch -- upper ) dup letter? [ HEX: 20 - ] when ; inline
: >upper ( str -- upper ) [ ch>upper ] map ;

HINTS: >lower string ;
HINTS: >upper string ;