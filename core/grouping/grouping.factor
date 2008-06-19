! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.order strings arrays vectors sequences
accessors ;
IN: grouping

TUPLE: abstract-groups seq n ;

: check-groups dup 0 <= [ "Invalid group count" throw ] when ; inline

: new-groups ( seq n class -- groups )
    >r check-groups r> boa ; inline

GENERIC: group@ ( n groups -- from to seq )

M: abstract-groups nth group@ subseq ;

M: abstract-groups set-nth group@ <slice> 0 swap copy ;

M: abstract-groups like drop { } like ;

INSTANCE: abstract-groups sequence

TUPLE: groups < abstract-groups ;

: <groups> ( seq n -- groups )
    groups new-groups ; inline

M: groups length
    [ seq>> length ] [ n>> ] bi [ + 1- ] keep /i ;

M: groups set-length
    [ n>> * ] [ seq>> ] bi set-length ;

M: groups group@
    [ n>> [ * dup ] keep + ] [ seq>> ] bi [ length min ] keep ;

TUPLE: sliced-groups < groups ;

: <sliced-groups> ( seq n -- groups )
    sliced-groups new-groups ; inline

M: sliced-groups nth group@ <slice> ;

TUPLE: clumps < abstract-groups ;

: <clumps> ( seq n -- clumps )
    clumps new-groups ; inline

M: clumps length
    [ seq>> length ] [ n>> ] bi - 1+ ;

M: clumps set-length
    [ n>> + 1- ] [ seq>> ] bi set-length ;

M: clumps group@
    [ n>> over + ] [ seq>> ] bi ;

TUPLE: sliced-clumps < clumps ;

: <sliced-clumps> ( seq n -- clumps )
    sliced-clumps new-groups ; inline

M: sliced-clumps nth group@ <slice> ;

: group ( seq n -- array ) <groups> { } like ;

: clump ( seq n -- array ) <clumps> { } like ;
