! Copyright (C) 2008, 2009 Doug Coleman, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel arrays accessors fry sequences regexp.classes ;
FROM: math.ranges => [a,b] ;
IN: regexp.ast

TUPLE: negation term ;
C: <negation> negation

TUPLE: from-to n m ;
C: <from-to> from-to

TUPLE: at-least n ;
C: <at-least> at-least

SINGLETON: epsilon

TUPLE: concatenation first second ;

: <concatenation> ( seq -- concatenation )
    [ epsilon ] [ unclip [ concatenation boa ] reduce ] if-empty ;

TUPLE: alternation first second ;

: <alternation> ( seq -- alternation )
    unclip [ alternation boa ] reduce ;

TUPLE: star term ;
C: <star> star

TUPLE: with-options tree options ;
C: <with-options> with-options

TUPLE: options on off ;
C: <options> options

SINGLETONS: unix-lines dotall multiline comments case-insensitive
unicode-case reversed-regexp ;

: <maybe> ( term -- term' )
    f <concatenation> 2array <alternation> ;

: <plus> ( term -- term' )
    dup <star> 2array <concatenation> ;

: repetition ( n term -- term' )
    <array> <concatenation> ;

GENERIC: <times> ( term times -- term' )
M: at-least <times>
    n>> swap [ repetition ] [ <star> ] bi 2array <concatenation> ;
M: from-to <times>
    [ n>> ] [ m>> ] bi [a,b] swap '[ _ repetition ] map <alternation> ;

: char-class ( ranges ? -- term )
    [ <or-class> ] dip [ <not-class> ] when ;

TUPLE: lookahead term ;
C: <lookahead> lookahead

TUPLE: lookbehind term ;
C: <lookbehind> lookbehind
