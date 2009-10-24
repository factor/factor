! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.order strings arrays vectors sequences
sequences.private accessors fry ;
IN: grouping

<PRIVATE

TUPLE: chunking-seq { seq read-only } { n read-only } ;

: check-groups ( n -- n )
    dup 0 <= [ "Invalid group count" throw ] when ; inline

: new-groups ( seq n class -- groups )
    [ check-groups ] dip boa ; inline

GENERIC: group@ ( n groups -- from to seq )

M: chunking-seq set-nth group@ <slice> 0 swap copy ;

M: chunking-seq like drop { } like ; inline

INSTANCE: chunking-seq sequence

MIXIN: subseq-chunking

M: subseq-chunking nth group@ subseq ; inline

MIXIN: slice-chunking

M: slice-chunking nth group@ <slice> ; inline

M: slice-chunking nth-unsafe group@ slice boa ; inline

TUPLE: abstract-groups < chunking-seq ;

M: abstract-groups length
    [ seq>> length ] [ n>> ] bi [ + 1 - ] keep /i ; inline

M: abstract-groups set-length
    [ n>> * ] [ seq>> ] bi set-length ; inline

M: abstract-groups group@
    [ n>> [ * dup ] keep + ] [ seq>> ] bi [ length min ] keep ; inline

TUPLE: abstract-clumps < chunking-seq ;

M: abstract-clumps length
    [ seq>> length 1 + ] [ n>> ] bi [-] ; inline

M: abstract-clumps set-length
    [ n>> + 1 - ] [ seq>> ] bi set-length ; inline

M: abstract-clumps group@
    [ n>> over + ] [ seq>> ] bi ; inline

PRIVATE>

TUPLE: groups < abstract-groups ;

: <groups> ( seq n -- groups )
    groups new-groups ; inline

INSTANCE: groups subseq-chunking

TUPLE: sliced-groups < abstract-groups ;

: <sliced-groups> ( seq n -- groups )
    sliced-groups new-groups ; inline

INSTANCE: sliced-groups slice-chunking

TUPLE: clumps < abstract-clumps ;

: <clumps> ( seq n -- clumps )
    clumps new-groups ; inline

INSTANCE: clumps subseq-chunking

TUPLE: sliced-clumps < abstract-clumps ;

: <sliced-clumps> ( seq n -- clumps )
    sliced-clumps new-groups ; inline

INSTANCE: sliced-clumps slice-chunking

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
