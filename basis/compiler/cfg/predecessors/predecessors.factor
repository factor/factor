! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors combinators fry sequences assocs compiler.cfg.rpo
compiler.cfg.instructions ;
IN: compiler.cfg.predecessors

: update-predecessors ( bb -- )
    dup successors>> [ predecessors>> push ] with each ;

: update-phi ( bb ##phi -- )
    [
        swap predecessors>>
        '[ drop _ memq? ] assoc-filter
    ] change-inputs drop ;

: update-phis ( bb -- )
    dup instructions>> [
        dup ##phi? [ update-phi ] [ 2drop ] if
    ] with each ;

: compute-predecessors ( cfg -- cfg' )
    {
        [ [ V{ } clone >>predecessors drop ] each-basic-block ]
        [ [ update-predecessors ] each-basic-block ]
        [ [ update-phis ] each-basic-block ]
        [ ]
    } cleave ;
