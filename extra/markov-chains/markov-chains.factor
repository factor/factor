! Copyright (C) 2020 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: assocs assocs.extras assocs.private fry grouping kernel
math.extras random sequences ;

IN: markov-chains

: transitions ( string -- clumps )
    { t } { f } surround 2 clump ;

: push-transitions ( table seq -- table )
    transitions over [
        [ drop H{ } clone ] cache inc-at
    ] with-assoc assoc-each ;

: transition-table ( seq -- table )
    H{ } clone swap [ push-transitions ] each ;

: markov-chain ( table -- seq )
    t swap '[ _ at weighted-random dup ] [ dup ] produce nip ;
