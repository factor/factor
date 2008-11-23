! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math math.order symbols regexp.parser
words regexp.utils unicode.categories combinators.short-circuit ;
IN: regexp.classes

GENERIC: class-member? ( obj class -- ? )

M: word class-member? ( obj class -- ? ) 2drop f ;
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
