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
    [ seq>> length 1 + ] [ n>> ] bi - 1 max ; inline

M: abstract-clumps set-length
    [ n>> + 1 - ] [ seq>> ] bi set-length ; inline

M: abstract-clumps group@
    [ [ n>> over + ] [ seq>> length ] bi min ] [ seq>> ] bi ; inline

TUPLE: chunking-seq { seq read-only } { n read-only } ;

: check-groups ( seq n -- seq n )
    dup 0 <= [ groups-error ] when ; inline

: new-groups ( seq n class -- groups )
    [ check-groups ] dip boa ; inline

: slice-mod ( n length -- n' )
    2dup >= [ - ] [ drop ] if ; inline

: check-circular-clumps ( seq n -- seq n )
    2dup 1 - swap bounds-check 2drop ; inline

PRIVATE>

TUPLE: groups < chunking-seq ;
INSTANCE: groups subseq-chunking
INSTANCE: groups abstract-groups

: <groups> ( seq n -- groups )
    groups new-groups ; inline

TUPLE: sliced-groups < chunking-seq ;
INSTANCE: sliced-groups slice-chunking
INSTANCE: sliced-groups abstract-groups

: <sliced-groups> ( seq n -- groups )
    sliced-groups new-groups ; inline

TUPLE: clumps < chunking-seq ;
INSTANCE: clumps subseq-chunking
INSTANCE: clumps abstract-clumps

: <clumps> ( seq n -- clumps )
    clumps new-groups ; inline

TUPLE: sliced-clumps < chunking-seq ;
INSTANCE: sliced-clumps slice-chunking
INSTANCE: sliced-clumps abstract-clumps

: <sliced-clumps> ( seq n -- clumps )
    sliced-clumps new-groups ; inline

: group ( seq n -- array ) <groups> { } like ;

: clump ( seq n -- array ) <clumps> { } like ;

: monotonic? ( seq quot: ( elt1 elt2 -- ? ) -- ? )
    over length 2 < [ 2drop t ] [
        over length 2 = [
            [ first2-unsafe ] dip call
        ] [
            [ 2 <sliced-clumps> ] dip
            '[ first2-unsafe @ ] all?
        ] if
    ] if ; inline

: all-equal? ( seq -- ? ) [ = ] monotonic? ;

: all-eq? ( seq -- ? ) [ eq? ] monotonic? ;

TUPLE: circular-slice { from read-only } { to read-only } { seq read-only } ;

INSTANCE: circular-slice virtual-sequence

M: circular-slice equal? over slice? [ sequence= ] [ 2drop f ] if ;

M: circular-slice hashcode* [ sequence-hashcode ] recursive-hashcode ;

M: circular-slice length [ to>> ] [ from>> ] bi - ; inline

M: circular-slice virtual-exemplar seq>> ; inline

M: circular-slice virtual@
    [ from>> + ] [ seq>> ] bi [ length slice-mod ] keep ; inline

C: <circular-slice> circular-slice

TUPLE: sliced-circular-clumps < chunking-seq ;
INSTANCE: sliced-circular-clumps sequence

M: sliced-circular-clumps length
    seq>> length ; inline

M: sliced-circular-clumps nth
    [ n>> over + ] [ seq>> ] bi <circular-slice> ; inline

: <sliced-circular-clumps> ( seq n -- clumps )
    check-circular-clumps sliced-circular-clumps boa ; inline

TUPLE: circular-clumps < chunking-seq ;
INSTANCE: circular-clumps sequence

M: circular-clumps length
    seq>> length ; inline

M: circular-clumps nth
    [ n>> over + ] [ seq>> ] bi [ <circular-slice> ] [ like ] bi ; inline

: <circular-clumps> ( seq n -- clumps )
    check-circular-clumps circular-clumps boa ; inline

: circular-clump ( seq n -- array )
    <circular-clumps> { } like ; inline
