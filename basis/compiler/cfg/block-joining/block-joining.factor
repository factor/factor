! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators.short-circuit kernel namespaces
sequences math compiler.utilities compiler.cfg
compiler.cfg.instructions compiler.cfg.rpo
compiler.cfg.predecessors compiler.cfg.utilities ;
IN: compiler.cfg.block-joining

! Joining blocks that are not calls and are connected by a single CFG edge.
! This pass does not update ##phi nodes and should therefore only run
! before stack analysis.
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

: join-unlikely ( bb pred -- )
    over unlikely?>> [ t >>unlikely? ] when 2drop ;

: join-block ( bb pred -- )
    [ join-instructions ]
    [ update-successors ]
    [ join-unlikely ]
    2tri ;

SYMBOL: changed?

: join-blocks ( cfg -- cfg' )
    needs-predecessors

    dup post-order [
        dup join-block?
        [ changed? on dup predecessor join-block ] [ drop ] if
    ] each

    changed? get [ cfg-changed predecessors-changed ] when ;
