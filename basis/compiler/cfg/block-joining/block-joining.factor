! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators combinators.short-circuit
compiler.cfg compiler.cfg.predecessors compiler.cfg.rpo
compiler.cfg.utilities kernel sequences ;
IN: compiler.cfg.block-joining

: join-block? ( bb -- ? )
    {
        [ kill-block?>> not ]
        [ predecessors>> length 1 = ]
        [ predecessor kill-block?>> not ]
        [ predecessor successors>> length 1 = ]
        [ [ predecessor ] keep back-edge? not ]
    } 1&& ;

: join-instructions ( bb pred -- )
    [ instructions>> ] bi@ dup pop* push-all ;

: update-successors ( bb pred -- )
    [ successors>> ] dip successors<< ;

: join-block ( bb pred -- )
    [ join-instructions ] [ update-successors ] 2bi ;

: join-blocks ( cfg -- )
    {
        [ needs-predecessors ]
        [
            post-order [
                dup join-block?
                [ dup predecessor join-block ] [ drop ] if
            ] each
        ]
        [ cfg-changed ]
        [ predecessors-changed ]
    } cleave ;
