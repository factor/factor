! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: unparser
USING: generic kernel lists math memory namespaces parser
sequences sequences stdio strings words ;

GENERIC: unparse ( obj -- str )

M: object unparse ( obj -- str )
    [
        "#<" ,
        dup class unparse ,
        " @ " , 
        address unparse ,
        ">" ,
    ] make-string ;

: >digit ( n -- ch )
    dup 10 < [ CHAR: 0 + ] [ 10 - CHAR: a + ] ifte ;

: integer, ( num radix -- )
    dup >r /mod >digit , dup 0 > [
        r> integer,
    ] [
        r> 2drop
    ] ifte ;

: >base ( num radix -- string )
    #! Convert a number to a string in a certain base.
    [
        over 0 < [
            swap neg swap integer, CHAR: - ,
        ] [
            integer,
        ] ifte
    ] make-rstring ;

: >dec ( num -- string ) 10 >base ;
: >bin ( num -- string ) 2 >base ;
: >oct ( num -- string ) 8 >base ;
: >hex ( num -- string ) 16 >base ;

M: fixnum unparse ( obj -- str ) >dec ;
M: bignum unparse ( obj -- str ) >dec ;

M: ratio unparse ( num -- str )
    [
        dup
        numerator unparse ,
        CHAR: / ,
        denominator unparse ,
    ] make-string ;

: fix-float ( str -- str )
    #! This is terrible. Will go away when we do our own float
    #! output.
    "." over string-contains? [ ".0" cat2 ] unless ;

M: float unparse ( float -- str )
    (unparse-float) fix-float ;

M: complex unparse ( num -- str )
    [
        "#{ " ,
        dup
        real unparse ,
        " " ,
        imaginary unparse ,
        " }#" ,
    ] make-string ;

: ch>ascii-escape ( ch -- esc )
    [
        [[ CHAR: \e "\\e"  ]]
        [[ CHAR: \n "\\n"  ]]
        [[ CHAR: \r "\\r"  ]]
        [[ CHAR: \t "\\t"  ]]
        [[ CHAR: \0 "\\0"  ]]
        [[ CHAR: \\ "\\\\" ]]
        [[ CHAR: \" "\\\"" ]]
    ] assoc ;

: ch>unicode-escape ( ch -- esc )
    >hex 4 "0" pad "\\u" swap cat2 ;

: unparse-ch ( ch -- ch/str )
    dup quotable? [
        dup ch>ascii-escape [ ] [ ch>unicode-escape ] ?ifte
    ] unless ;

: unparse-string [ unparse-ch , ] seq-each ;

M: string unparse ( str -- str )
    [ CHAR: " , unparse-string CHAR: " , ] make-string ;

M: sbuf unparse ( str -- str )
    [ "s\" " , unparse-string CHAR: " , ] make-string ;

M: word unparse ( obj -- str ) word-name dup "#<unnamed>" ? ;

M: t unparse drop "t" ;
M: f unparse drop "f" ;
