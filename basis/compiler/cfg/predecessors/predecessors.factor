! Copyright (C) 2008, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs compiler.cfg.rpo compiler.cfg.utilities
kernel sequences ;
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

: compute-predecessors ( cfg -- )
    [ [ V{ } clone >>predecessors drop ] each-basic-block ]
    [ [ update-predecessors ] each-basic-block ]
    [ [ update-phis ] each-basic-block ] tri ;

PRIVATE>

: needs-predecessors ( cfg -- )
    dup predecessors-valid?>> [ drop ]
    [ t >>predecessors-valid? compute-predecessors ] if ;
