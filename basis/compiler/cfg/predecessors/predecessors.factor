! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors combinators fry sequences assocs compiler.cfg.rpo
compiler.cfg.instructions compiler.cfg.utilities ;
IN: compiler.cfg.predecessors

<PRIVATE

: update-predecessors ( bb -- )
    dup successors>> [ predecessors>> push ] with each ;

: update-phi ( bb ##phi -- )
    [
        swap predecessors>>
        '[ drop _ member-eq? ] assoc-filter
    ] change-inputs drop ;

: update-phis ( bb -- )
    dup [ update-phi ] with each-phi ;

: compute-predecessors ( cfg -- cfg' )
    {
        [ [ V{ } clone >>predecessors drop ] each-basic-block ]
        [ [ update-predecessors ] each-basic-block ]
        [ [ update-phis ] each-basic-block ]
        [ ]
    } cleave ;

PRIVATE>

: needs-predecessors ( cfg -- cfg' )
    dup predecessors-valid?>>
    [ compute-predecessors t >>predecessors-valid? ] unless ;
