! Copyright (C) 2008, 2009 Doug Coleman, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel arrays accessors fry sequences ;
FROM: math.ranges => [a,b] ;
IN: regexp.ast

TUPLE: primitive-class class ;
C: <primitive-class> primitive-class

TUPLE: negation term ;
C: <negation> negation

TUPLE: from-to n m ;
C: <from-to> from-to

TUPLE: at-least n ;
C: <at-least> at-least

TUPLE: concatenation seq ;
C: <concatenation> concatenation

TUPLE: alternation seq ;
C: <alternation> alternation

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
    [ <alternation> ] dip [ <negation> ] when ;
