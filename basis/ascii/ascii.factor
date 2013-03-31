! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.short-circuit hints kernel math math.order
sequences splitting strings ;
IN: ascii

: ascii? ( ch -- ? ) 0 127 between? ; inline
: blank? ( ch -- ? ) " \t\n\r" member? ; inline
: letter? ( ch -- ? ) CHAR: a CHAR: z between? ; inline
: LETTER? ( ch -- ? ) CHAR: A CHAR: Z between? ; inline
: digit? ( ch -- ? ) CHAR: 0 CHAR: 9 between? ; inline
: printable? ( ch -- ? ) CHAR: \s CHAR: ~ between? ; inline
: control? ( ch -- ? ) { [ 0 0x1F between? ] [ 0x7F = ] } 1|| ; inline
: quotable? ( ch -- ? ) { [ printable? ] [ "\"\\" member? not ] } 1&& ; inline
: Letter? ( ch -- ? ) { [ letter? ] [ LETTER? ] } 1|| ; inline
: alpha? ( ch -- ? ) { [ Letter? ] [ digit? ] } 1|| ; inline
: ch>lower ( ch -- lower ) dup LETTER? [ 0x20 + ] when ; inline
: >lower ( str -- lower ) [ ch>lower ] map ;
: ch>upper ( ch -- upper ) dup letter? [ 0x20 - ] when ; inline
: >upper ( str -- upper ) [ ch>upper ] map ;
: >words ( str -- words ) [ blank? ] split*-when-slice ;
: capitalize ( str -- str' ) unclip [ >lower ] [ ch>upper ] bi* prefix ;
: >title ( str -- title ) >words [ capitalize ] map concat ;

HINTS: >lower string ;
HINTS: >upper string ;
