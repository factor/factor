! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators concurrency.count-downs
concurrency.futures generalizations kernel locals sequences
sequences.private sequences.product threads ;
IN: concurrency.combinators

<PRIVATE

: parallel ( n quot -- )
    [ <count-down> ] dip keep await ; inline

! Share the completion wrapper across the group, then bind each task's inputs.
: stage-quot ( quot count-down -- quot' promise )
    [ '[ @ _ count-down ] ] [ promise>> ] bi ; inline

PRIVATE>

: parallel-each ( seq quot: ( elt -- ) -- )
    over length [
        stage-quot '[ _ curry "Count down stage" _ spawn-linked-to drop ] each
    ] parallel ; inline

: parallel-each-index ( seq quot: ( elt index -- ) -- )
    over length [
        stage-quot '[ _ 2curry "Count down stage" _ spawn-linked-to drop ] each-index
    ] parallel ; inline

: 2parallel-each ( seq1 seq2 quot: ( elt1 elt2 -- ) -- )
    2over min-length [
        stage-quot '[ _ 2curry "Count down stage" _ spawn-linked-to drop ] 2each
    ] parallel ; inline

: parallel-product-each ( seq quot: ( elt -- ) -- )
    [ <product-sequence> ] dip parallel-each ;

: parallel-cartesian-each ( seq1 seq2 quot: ( elt1 elt2 -- ) -- )
    [ 2array ] dip [ first2-unsafe ] prepose parallel-product-each ;

:: parallel-map-as ( seq quot: ( elt -- newelt ) exemplar -- newseq )
    seq length exemplar new-sequence :> result
    seq [| elt index | elt quot call index result set-nth ] parallel-each-index
    result exemplar like ; inline

: parallel-map ( seq quot: ( elt -- newelt ) -- newseq )
    over parallel-map-as ; inline

:: parallel-filter ( seq quot: ( elt -- ? ) -- newseq )
    seq quot { } parallel-map-as :> matches
    V{ } clone :> result
    seq matches [ [ result push ] [ drop ] if ] 2each
    result seq like ; inline

: parallel-assoc-map-as ( assoc quot: ( key value -- newkey newvalue ) exemplar -- newassoc )
    [ >alist ] [ '[ first2 @ 2array ] parallel-map ] [ assoc-like ] tri* ; inline

: parallel-assoc-map ( assoc quot: ( key value -- newkey newvalue ) -- newassoc )
    over parallel-assoc-map-as ;

: 2parallel-map ( seq1 seq2 quot: ( elt1 elt2 -- newelt ) -- newseq )
    '[ _ 2curry future ] 2map [ ?future ] map ;

: parallel-product-map ( seq quot: ( elt -- newelt ) -- newseq )
    [ <product-sequence> ] dip parallel-map ;

: parallel-cartesian-map ( seq1 seq2 quot: ( elt1 elt2 -- newelt ) -- newseq )
    [ 2array ] dip [ first2-unsafe ] prepose parallel-product-map ;

<PRIVATE

: [future] ( quot -- quot' ) '[ _ curry future ] ; inline

: (parallel-spread) ( n -- spread-array )
    [ ?future ] <repetition> ; inline

: (parallel-cleave) ( quots -- quot-array spread-array )
    [ [future] ] map dup length (parallel-spread) ; inline

PRIVATE>

MACRO: parallel-cleave ( quots -- quot )
    (parallel-cleave) '[ _ cleave _ spread ] ;

MACRO: parallel-spread ( quots -- quot )
    (parallel-cleave) '[ _ spread _ spread ] ;

MACRO: parallel-napply ( quot n -- quot )
    [ [future] ] dip dup (parallel-spread) '[ _ _ napply _ spread ] ;
