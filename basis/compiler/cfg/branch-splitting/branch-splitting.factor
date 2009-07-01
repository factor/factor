! Copyright (C) 2009 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators.short-circuit kernel math sequences
compiler.cfg.def-use compiler.cfg compiler.cfg.rpo ;
IN: compiler.cfg.branch-splitting

! Predecessors must be recomputed after this

: split-branch-for ( bb predecessor -- )
    [
        [
            <basic-block>
                swap
                [ instructions>> [ clone ] map >>instructions ]
                [ successors>> clone >>successors ]
                bi
        ] keep
    ] dip
    [ [ 2dup eq? [ 2drop ] [ 2nip ] if ] with with map ] change-successors
    drop ;

: split-branch ( bb -- )
    dup predecessors>> [ split-branch-for ] with each ;

: split-branches? ( bb -- ? )
    {
        [ successors>> empty? ]
        [ predecessors>> length 1 > ]
        [ instructions>> [ defs-vregs ] any? not ]
        [ instructions>> [ temp-vregs ] any? not ]
    } 1&& ;

: split-branches ( cfg -- cfg' )
    dup [
        dup split-branches? [ split-branch ] [ drop ] if
    ] each-basic-block
    f >>post-order ;
