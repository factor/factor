! Copyright (C) 2008, 2009 Doug Coleman, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math math.order words
ascii unicode.categories combinators.short-circuit sequences ;
IN: regexp.classes

: punct? ( ch -- ? )
    "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~" member? ;

: c-identifier-char? ( ch -- ? )
    { [ alpha? ] [ CHAR: _ = ] } 1|| ;

: java-blank? ( ch -- ? )
    {
        CHAR: \s CHAR: \t CHAR: \n
        HEX: b HEX: 7 CHAR: \r
    } member? ;

: java-printable? ( ch -- ? )
    [ [ alpha? ] [ punct? ] ] 1|| ;

: hex-digit? ( ch -- ? )
    {
        [ CHAR: A CHAR: F between? ]
        [ CHAR: a CHAR: f between? ]
        [ CHAR: 0 CHAR: 9 between? ]
    } 1|| ;

SINGLETONS: any-char any-char-no-nl
letter-class LETTER-class Letter-class digit-class
alpha-class non-newline-blank-class
ascii-class punctuation-class java-printable-class blank-class
control-character-class hex-digit-class java-blank-class c-identifier-class
unmatchable-class terminator-class word-boundary-class ;

SINGLETONS: beginning-of-input beginning-of-line
end-of-input end-of-line ;

TUPLE: range from to ;
C: <range> range

GENERIC: class-member? ( obj class -- ? )

! When does t get put in?
M: t class-member? ( obj class -- ? ) 2drop f ;

M: integer class-member? ( obj class -- ? ) = ;

M: range class-member? ( obj class -- ? )
    [ from>> ] [ to>> ] bi between? ;

M: any-char class-member? ( obj class -- ? )
    2drop t ;

M: any-char-no-nl class-member? ( obj class -- ? )
    drop CHAR: \n = not ;

M: letter-class class-member? ( obj class -- ? )
    drop letter? ;
            
M: LETTER-class class-member? ( obj class -- ? )
    drop LETTER? ;

M: Letter-class class-member? ( obj class -- ? )
    drop Letter? ;

M: ascii-class class-member? ( obj class -- ? )
    drop ascii? ;

M: digit-class class-member? ( obj class -- ? )
    drop digit? ;

M: c-identifier-class class-member? ( obj class -- ? )
    drop
    { [ digit? ] [ Letter? ] [ CHAR: _ = ] } 1|| ;

M: alpha-class class-member? ( obj class -- ? )
    drop alpha? ;

M: punctuation-class class-member? ( obj class -- ? )
    drop punct? ;

M: java-printable-class class-member? ( obj class -- ? )
    drop java-printable? ;

M: non-newline-blank-class class-member? ( obj class -- ? )
    drop { [ blank? ] [ CHAR: \n = not ] } 1&& ;

M: control-character-class class-member? ( obj class -- ? )
    drop control? ;

M: hex-digit-class class-member? ( obj class -- ? )
    drop hex-digit? ;

M: java-blank-class class-member? ( obj class -- ? )
    drop java-blank? ;

M: unmatchable-class class-member? ( obj class -- ? )
    2drop f ;

M: terminator-class class-member? ( obj class -- ? )
    drop {
        [ CHAR: \r = ]
        [ CHAR: \n = ]
        [ CHAR: \u000085 = ]
        [ CHAR: \u002028 = ]
        [ CHAR: \u002029 = ]
    } 1|| ;

M: beginning-of-line class-member? ( obj class -- ? )
    2drop f ;

M: end-of-line class-member? ( obj class -- ? )
    2drop f ;

TUPLE: or-class seq ;
C: <or-class> or-class

TUPLE: not-class class ;
C: <not-class> not-class

TUPLE: primitive-class class ;
C: <primitive-class> primitive-class

M: or-class class-member?
    seq>> [ class-member? ] with any? ;

M: not-class class-member?
    class>> class-member? not ;

M: primitive-class class-member?
    class>> class-member? ;
