! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math math.order words regexp.utils
unicode.categories combinators.short-circuit ;
IN: regexp.classes

SINGLETONS: any-char any-char-no-nl
letter-class LETTER-class Letter-class digit-class
alpha-class non-newline-blank-class
ascii-class punctuation-class java-printable-class blank-class
control-character-class hex-digit-class java-blank-class c-identifier-class
unmatchable-class terminator-class word-boundary-class ;

SINGLETONS: beginning-of-input beginning-of-line
end-of-input end-of-line ;

MIXIN: node
TUPLE: character-class-range from to ; INSTANCE: character-class-range node

GENERIC: class-member? ( obj class -- ? )

M: t class-member? ( obj class -- ? ) 2drop f ;

M: integer class-member? ( obj class -- ? ) 2drop f ;

M: character-class-range class-member? ( obj class -- ? )
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
    drop control-char? ;

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
