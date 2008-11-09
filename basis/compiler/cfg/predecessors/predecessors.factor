! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences compiler.cfg.rpo ;
IN: compiler.cfg.predecessors

: (compute-predecessors) ( bb -- )
    dup successors>> [ predecessors>> push ] with each ;

: compute-predecessors ( cfg -- cfg' )
    dup [ (compute-predecessors) ] each-basic-block ;
