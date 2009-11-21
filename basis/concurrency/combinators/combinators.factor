! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: concurrency.futures concurrency.count-downs sequences
kernel macros fry combinators generalizations ;
IN: concurrency.combinators

<PRIVATE

: (parallel-each) ( n quot -- )
    [ <count-down> ] dip keep await ; inline

PRIVATE>

: parallel-each ( seq quot -- )
    over length [
        '[ _ curry _ spawn-stage ] each
    ] (parallel-each) ; inline

: 2parallel-each ( seq1 seq2 quot -- )
    2over min-length [
        '[ _ 2curry _ spawn-stage ] 2each
    ] (parallel-each) ; inline

: parallel-filter ( seq quot -- newseq )
    over [ pusher [ parallel-each ] dip ] dip like ; inline

<PRIVATE

: [future] ( quot -- quot' ) '[ _ curry future ] ; inline

: future-values ( futures -- futures )
    [ ?future ] map! ; inline

PRIVATE>

: parallel-map ( seq quot -- newseq )
    [future] map future-values ; inline

: 2parallel-map ( seq1 seq2 quot -- newseq )
    '[ _ 2curry future ] 2map future-values ;

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
