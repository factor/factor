! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: compiler.cfg kernel accessors sequences ;
IN: compiler.cfg.predecessors

! Pass to compute precedecessors.

: compute-predecessors ( procedure -- )
    [
        dup successors>>
        [ predecessors>> push ] with each
    ] each-block ;
