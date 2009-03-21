! Copyright (C) 2008, 2009 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: unicode.data kernel math sequences parser unicode.data.private
bit-arrays namespaces sequences.private arrays classes.parser
assocs classes.predicate sets fry splitting accessors ;
IN: unicode.categories.syntax

! For use in CATEGORY:
SYMBOLS: Cn Lu Ll Lt Lm Lo Mn Mc Me Nd Nl No Pc Pd Ps Pe Pi Pf Po Sm Sc Sk So Zs Zl Zp Cc Cf Cs Co | ;

<PRIVATE

: [category] ( categories code -- quot )
    '[ dup category# _ member? [ drop t ] _ if ] ;

: integer-predicate-class ( word predicate -- )
    integer swap define-predicate-class ;

: define-category ( word categories code -- )
    [category] integer-predicate-class ;

: define-not-category ( word categories code -- )
    [category] [ not ] compose integer-predicate-class ;

: parse-category ( -- word tokens quot )
    CREATE-CLASS \ ; parse-until { | } split1
    [ [ name>> categories-map at ] map ]
    [ [ [ ] like ] [ [ drop f ] ] if* ] bi* ;

PRIVATE>

SYNTAX: CATEGORY: parse-category define-category ;

SYNTAX: CATEGORY-NOT: parse-category define-not-category ;
