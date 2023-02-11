! Copyright (C) 2009, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors compiler.cfg.rpo kernel sequences ;
IN: compiler.cfg.checker

ERROR: bad-successors ;

: check-successors ( bb -- )
    dup successors>> [ predecessors>> member-eq? ] with all?
    [ bad-successors ] unless ;

: check-cfg ( cfg -- )
    [ check-successors ] each-basic-block ;
