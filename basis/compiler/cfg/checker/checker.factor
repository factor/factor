! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors compiler.cfg.rpo kernel sequences ;
IN: compiler.cfg.checker

ERROR: bad-successors ;

: check-successors ( bb -- )
    dup successors>> '[ _ predecessors>> member-eq-of? ] all?
    [ bad-successors ] unless ;

: check-cfg ( cfg -- )
    [ check-successors ] each-basic-block ;
