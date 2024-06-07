! Copyright (C) 2005, 2010 Slava Pestov, Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel math math.order sequences
sequences.private ;
IN: grouping

ERROR: groups-error seq n ;

<PRIVATE

GENERIC: group@ ( n groups -- from to seq )

TUPLE: chunking { seq read-only } { n read-only } ;

INSTANCE: chunking sequence

M: chunking nth-unsafe group@ <slice-unsafe> ; inline

M: chunking set-nth-unsafe group@ <slice-unsafe> 0 swap copy ;

M: chunking like drop { } like ; inline

: check-groups ( seq n -- seq n )
    dup 0 <= [ groups-error ] when ; inline

: new-groups ( seq n class -- groups )
    [ check-groups ] dip boa ; inline

PRIVATE>

TUPLE: groups < chunking ;

M: groups length
    [ seq>> length ] [ n>> ] bi [ + 1 - ] keep /i ; inline

M: groups set-length
    [ n>> * ] [ seq>> ] bi set-length ; inline

M: groups group@
    [ n>> [ * dup ] keep + ] [ seq>> ] bi [ length min ] keep ; inline

: <groups> ( seq n -- groups )
    groups new-groups ; inline

TUPLE: clumps < chunking ;

M: clumps length
    dup seq>> length [ drop 0 ] [
        swap [ 1 + ] [ n>> ] bi* [-]
    ] if-zero ; inline

M: clumps set-length
    [ n>> + 1 - ] [ seq>> ] bi set-length ; inline

M: clumps group@
    [ n>> over + ] [ seq>> ] bi ; inline

: <clumps> ( seq n -- clumps )
    clumps new-groups ; inline

<PRIVATE

: map-like ( seq n quot -- seq )
    keepd '[ _ like ] map ; inline

PRIVATE>

: group ( seq n -- array ) [ <groups> ] map-like ; inline

: clump ( seq n -- array ) [ <clumps> ] map-like ; inline

: monotonic? ( seq quot: ( elt1 elt2 -- ? ) -- ? )
    over length dup 2 < [ 3drop t ] [
        2 = [
            [ first2-unsafe ] dip call
        ] [
            [
                [ first-unsafe ]
                [ >underlying< [ nth-unsafe ] curry [ 1 + ] 2dip ] bi
            ] dip '[ @ _ guard ] all-integers-from? nip
        ] if
    ] if ; inline

: all-equal? ( seq -- ? ) [ = ] monotonic? ;

: all-eq? ( seq -- ? ) [ eq? ] monotonic? ;

TUPLE: circular-slice
    { from integer read-only }
    { to integer read-only }
    { seq read-only } ;

INSTANCE: circular-slice wrapped-sequence

M: circular-slice equal? over circular-slice? [ sequence= ] [ 2drop f ] if ;

M: circular-slice hashcode* [ sequence-hashcode ] recursive-hashcode ;

M: circular-slice length [ to>> ] [ from>> ] bi - ; inline

M: circular-slice virtual@
    [ from>> + ] [ seq>> ] bi [ length rem ] keep ; inline

C: <circular-slice> circular-slice

TUPLE: circular-clumps
    { seq read-only }
    { n read-only } ;

INSTANCE: circular-clumps sequence

M: circular-clumps length
    seq>> length ; inline

M: circular-clumps nth
    [ n>> over + ] [ seq>> ] bi <circular-slice> ; inline

: <circular-clumps> ( seq n -- clumps )
    circular-clumps new-groups ; inline

: circular-clump ( seq n -- array )
    [ <circular-clumps> ] map-like ; inline
