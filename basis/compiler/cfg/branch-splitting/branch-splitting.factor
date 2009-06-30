! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators.short-circuit compiler.cfg.def-use
compiler.cfg.rpo kernel math sequences ;
IN: compiler.cfg.branch-splitting

: split-branch ( branch -- )
    [
        [ instructions>> ] [ predecessors>> ] bi [
            instructions>> [ pop* ] [ push-all ] bi
        ] with each
    ] [
        [ successors>> ] [ predecessors>> ] bi [
            [ drop clone ] change-successors drop
        ] with each
    ] bi ;

: split-branches? ( bb -- ? )
    {
        [ predecessors>> length 1 >= ]
        [ successors>> length 1 <= ]
        [ instructions>> [ defs-vregs ] any? not ]
        [ instructions>> [ temp-vregs ] any? not ]
    } 1&& ;

: split-branches ( cfg -- cfg' )
    dup [
        dup split-branches? [ split-branch ] [ drop ] if
    ] each-basic-block f >>post-order ;
