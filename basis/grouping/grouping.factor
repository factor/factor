! Copyright (C) 2005, 2010 Slava Pestov, Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.order strings arrays vectors sequences
sequences.private accessors fry combinators ;
IN: grouping

ERROR: groups-error seq group-size ;
<PRIVATE

MIXIN: chunking
INSTANCE: chunking sequence

GENERIC: group@ ( n groups -- from to seq )

M: chunking set-nth group@ <slice> 0 swap copy ;
M: chunking like drop { } like ; inline

MIXIN: subseq-chunking
INSTANCE: subseq-chunking chunking
INSTANCE: subseq-chunking sequence

M: subseq-chunking nth group@ subseq ; inline

MIXIN: slice-chunking
INSTANCE: slice-chunking chunking
INSTANCE: slice-chunking sequence

M: slice-chunking nth group@ <slice> ; inline
M: slice-chunking nth-unsafe group@ <slice-unsafe> ; inline

MIXIN: abstract-groups
INSTANCE: abstract-groups sequence

M: abstract-groups length
    [ seq>> length ] [ n>> ] bi [ + 1 - ] keep /i ; inline

M: abstract-groups set-length
    [ n>> * ] [ seq>> ] bi set-length ; inline

M: abstract-groups group@
    [ n>> [ * dup ] keep + ] [ seq>> ] bi [ length min ] keep ; inline

MIXIN: abstract-clumps
INSTANCE: abstract-clumps sequence

M: abstract-clumps length
    dup seq>> length [ drop 0 ] [
        swap [ 1 + ] [ n>> ] bi* [-]
    ] if-zero ; inline

M: abstract-clumps set-length
    [ n>> + 1 - ] [ seq>> ] bi set-length ; inline

M: abstract-clumps group@
    [ n>> over + ] [ seq>> ] bi ; inline

TUPLE: chunking-seq { seq read-only } { n read-only } ;

: check-groups ( seq n -- seq n )
    dup 0 <= [ groups-error ] when ; inline

: new-groups ( seq n class -- groups )
    [ check-groups ] dip boa ; inline

PRIVATE>

TUPLE: groups < chunking-seq ;
INSTANCE: groups slice-chunking
INSTANCE: groups abstract-groups

: <groups> ( seq n -- groups )
    groups new-groups ; inline

TUPLE: clumps < chunking-seq ;
INSTANCE: clumps slice-chunking
INSTANCE: clumps abstract-clumps

: <clumps> ( seq n -- clumps )
    clumps new-groups ; inline

<PRIVATE

: map-like ( seq n quot -- seq )
    2keep drop '[ _ like ] map ; inline

PRIVATE>

: group ( seq n -- array ) [ <groups> ] map-like ; inline

: clump ( seq n -- array ) [ <clumps> ] map-like ; inline

: monotonic? ( seq quot: ( elt1 elt2 -- ? ) -- ? )
    over length dup 2 < [ 3drop t ] [
        2 = [
            [ first2-unsafe ] dip call
        ] [
            [ [ first-unsafe 1 ] [ ((each)) ] bi ] dip
            '[ @ _ keep swap ] (all-integers?) nip
        ] if
    ] if ; inline

: all-equal? ( seq -- ? ) [ = ] monotonic? ;

: all-eq? ( seq -- ? ) [ eq? ] monotonic? ;

TUPLE: circular-slice { from read-only } { to read-only } { seq read-only } ;

INSTANCE: circular-slice virtual-sequence

M: circular-slice equal? over circular-slice? [ sequence= ] [ 2drop f ] if ;

M: circular-slice hashcode* [ sequence-hashcode ] recursive-hashcode ;

M: circular-slice length [ to>> ] [ from>> ] bi - ; inline

M: circular-slice virtual-exemplar seq>> ; inline

M: circular-slice virtual@
    [ from>> + ] [ seq>> ] bi [ length rem ] keep ; inline

C: <circular-slice> circular-slice

TUPLE: circular-clumps < chunking-seq ;
INSTANCE: circular-clumps sequence

M: circular-clumps length
    seq>> length ; inline

M: circular-clumps nth
    [ n>> over + ] [ seq>> ] bi <circular-slice> ; inline

: <circular-clumps> ( seq n -- clumps )
    circular-clumps new-groups ; inline

: circular-clump ( seq n -- array )
    [ <circular-clumps> ] map-like ; inline
