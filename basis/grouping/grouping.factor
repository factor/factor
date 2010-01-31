! Copyright (C) 2005, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.order strings arrays vectors sequences
sequences.private accessors fry ;
IN: grouping

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
M: slice-chunking nth-unsafe group@ slice boa ; inline

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
    [ seq>> length 1 + ] [ n>> ] bi [-] ; inline

M: abstract-clumps set-length
    [ n>> + 1 - ] [ seq>> ] bi set-length ; inline

M: abstract-clumps group@
    [ n>> over + ] [ seq>> ] bi ; inline

TUPLE: chunking-seq { seq read-only } { n read-only } ;

: check-groups ( n -- n )
    dup 0 <= [ "Invalid group count" throw ] when ; inline

: new-groups ( seq n class -- groups )
    [ check-groups ] dip boa ; inline

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

: monotonic? ( seq quot -- ? )
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
