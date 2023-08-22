! Copyright (C) 2008 Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs classes.parser classes.predicate fry
kernel math parser sequences splitting unicode.data
unicode.data.private ;
IN: unicode.categories

! For use in CATEGORY:
SYMBOLS: Cn Lu Ll Lt Lm Lo Mn Mc Me Nd Nl No Pc Pd Ps Pe Pi Pf Po Sm Sc Sk So Zs Zl Zp Cc Cf Cs Co | ;

<PRIVATE

: [category] ( categories code -- quot )
    '[ integer>fixnum-strict dup category-num _ member? [ drop t ] _ if ] ;

: integer-predicate-class ( word predicate -- )
    integer swap define-predicate-class ;

: define-category ( word categories code -- )
    [category] integer-predicate-class ;

: define-not-category ( word categories code -- )
    [category] [ not ] compose integer-predicate-class ;

: parse-category ( -- word tokens quot )
    scan-new-class \ ; parse-until { | } split1
    [ [ name>> categories-map at ] B{ } map-as ]
    [ [ [ ] like ] [ [ drop f ] ] if* ] bi* ;

PRIVATE>

SYNTAX: CATEGORY: parse-category define-category ;

SYNTAX: CATEGORY-NOT: parse-category define-not-category ;
