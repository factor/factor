! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays combinators concurrency.count-downs
concurrency.futures fry generalizations kernel macros sequences
sequences.private sequences.product ;
IN: concurrency.combinators

<PRIVATE

: (parallel-each) ( n quot -- )
    [ <count-down> ] dip keep await ; inline

PRIVATE>

: parallel-each ( seq quot: ( elt -- ) -- )
    over length [
        '[ _ curry _ spawn-stage ] each
    ] (parallel-each) ; inline

: 2parallel-each ( seq1 seq2 quot: ( elt1 elt2 -- ) -- )
    2over min-length [
        '[ _ 2curry _ spawn-stage ] 2each
    ] (parallel-each) ; inline

: parallel-product-each ( seq quot: ( elt -- ) -- )
    [ <product-sequence> ] dip parallel-each ;

: parallel-cartesian-each ( seq1 seq2 quot: ( elt1 elt2 -- ) -- )
    [ 2array ] dip [ first2-unsafe ] prepose parallel-product-each ;

: parallel-filter ( seq quot: ( elt -- ? ) -- newseq )
    over [ selector [ parallel-each ] dip ] dip like ; inline

<PRIVATE

: [future] ( quot -- quot' ) '[ _ curry future ] ; inline

: future-values ( futures -- futures )
    [ ?future ] map! ; inline

PRIVATE>

: parallel-map ( seq quot: ( elt -- newelt ) -- newseq )
    [future] map future-values ; inline

: 2parallel-map ( seq1 seq2 quot: ( elt1 elt2 -- newelt ) -- newseq )
    '[ _ 2curry future ] 2map future-values ;

: parallel-product-map ( seq quot: ( elt -- newelt ) -- newseq )
    [ <product-sequence> ] dip parallel-map ;

: parallel-cartesian-map ( seq1 seq2 quot: ( elt1 elt2 -- newelt ) -- newseq )
    [ 2array ] dip [ first2-unsafe ] prepose parallel-product-map ;

<PRIVATE

: (parallel-spread) ( n -- spread-array )
    [ ?future ] <repetition> ; inline

: (parallel-cleave) ( quots -- quot-array spread-array )
    [ [future] ] map dup length (parallel-spread) ; inline

PRIVATE>

MACRO: parallel-cleave ( quots -- )
    (parallel-cleave) '[ _ cleave _ spread ] ;

MACRO: parallel-spread ( quots -- )
    (parallel-cleave) '[ _ spread _ spread ] ;

MACRO: parallel-napply ( quot n -- )
    [ [future] ] dip dup (parallel-spread) '[ _ _ napply _ spread ] ;
