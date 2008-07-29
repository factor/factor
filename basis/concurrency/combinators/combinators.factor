! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: concurrency.futures concurrency.count-downs sequences
kernel ;
IN: concurrency.combinators

: (parallel-each) ( n quot -- )
    >r <count-down> r> keep await ; inline

: parallel-each ( seq quot -- )
    over length [
        [ >r curry r> spawn-stage ] 2curry each
    ] (parallel-each) ; inline

: 2parallel-each ( seq1 seq2 quot -- )
    2over min-length [
        [ >r 2curry r> spawn-stage ] 2curry 2each
    ] (parallel-each) ; inline

: parallel-filter ( seq quot -- newseq )
    over >r pusher >r each r> r> like ; inline

: future-values dup [ ?future ] change-each ; inline

: parallel-map ( seq quot -- newseq )
    [ curry future ] curry map future-values ;
    inline

: 2parallel-map ( seq1 seq2 quot -- newseq )
    [ 2curry future ] curry 2map future-values ;
