! Copyright (C) 2008, 2009 Doug Coleman, Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel math regexp.classes sequences ;
IN: regexp.ast

TUPLE: negation term ;
C: <negation> negation

TUPLE: from-to n m ;
C: <from-to> from-to

TUPLE: at-least n ;
C: <at-least> at-least

TUPLE: tagged-epsilon tag ;
C: <tagged-epsilon> tagged-epsilon

CONSTANT: epsilon T{ tagged-epsilon { tag t } }

TUPLE: concatenation first second ;

: <concatenation> ( seq -- concatenation )
    [ epsilon ] [ [ ] [ concatenation boa ] map-reduce ] if-empty ;

TUPLE: alternation first second ;

: <alternation> ( seq -- alternation )
    [ ] [ alternation boa ] map-reduce ;

TUPLE: star term ;
C: <star> star

TUPLE: with-options tree options ;
C: <with-options> with-options

TUPLE: options on off ;
C: <options> options

SINGLETONS: unix-lines dotall multiline case-insensitive reversed-regexp ;

: <maybe> ( term -- term' )
    f <concatenation> 2array <alternation> ;

: <plus> ( term -- term' )
    dup <star> 2array <concatenation> ;

: repetition ( n term -- term' )
    <array> <concatenation> ;

GENERIC: <times> ( term times -- term' )

M: at-least <times>
    n>> swap [ repetition ] [ <star> ] bi 2array <concatenation> ;

: to-times ( term n -- ast )
    [ drop epsilon ]
    [ dupd 1 - to-times 2array <concatenation> <maybe> ]
    if-zero ;

M: from-to <times>
    [ n>> swap repetition ]
    [ [ m>> ] [ n>> ] bi - to-times ] 2bi
    2array <concatenation> ;

: char-class ( ranges ? -- term )
    [ <or-class> ] dip [ <not-class> ] when ;

TUPLE: lookahead term ;
C: <lookahead> lookahead

TUPLE: lookbehind term ;
C: <lookbehind> lookbehind
