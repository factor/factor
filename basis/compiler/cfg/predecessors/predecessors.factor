! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences compiler.cfg.rpo ;
IN: compiler.cfg.predecessors

: predecessors-step ( bb -- )
    dup successors>> [ predecessors>> push ] with each ;

: compute-predecessors ( cfg -- cfg' )
    [ [ V{ } clone >>predecessors drop ] each-basic-block ]
    [ [ predecessors-step ] each-basic-block ]
    [ ]
    tri ;
