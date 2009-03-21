! Copyright (C) 2008, 2009 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: unicode.data kernel math sequences parser
bit-arrays namespaces sequences.private arrays classes.parser
assocs classes.predicate sets fry splitting accessors ;
IN: unicode.categories.syntax

! For use in CATEGORY:
SYMBOLS: Cn Lu Ll Lt Lm Lo Mn Mc Me Nd Nl No Pc Pd Ps Pe Pi Pf Po Sm Sc Sk So Zs Zl Zp Cc Cf Cs Co | ;

<PRIVATE

: >category-array ( categories -- bitarray )
    categories [ swap member? ] with map >bit-array ;

: [category] ( categories code -- quot )
    [ >category-array ] dip
    '[ dup category# _ nth-unsafe [ drop t ] _ if ] ;

: define-category ( word categories code -- )
    [category] integer swap define-predicate-class ;

: parse-category ( -- word tokens quot )
    CREATE-CLASS \ ; parse-until { | } split1
    [ [ name>> ] map ]
    [ [ [ ] like ] [ [ drop f ] ] if* ] bi* ;

PRIVATE>

: CATEGORY:
    parse-category define-category ; parsing

: CATEGORY-NOT:
    parse-category
    [ categories swap diff ] dip
    define-category ; parsing
