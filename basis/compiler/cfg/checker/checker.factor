! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel combinators.short-circuit accessors math sequences
sets assocs compiler.cfg.instructions compiler.cfg.rpo
compiler.cfg.def-use compiler.cfg.linearization
compiler.cfg.utilities compiler.cfg.finalization
compiler.utilities ;
IN: compiler.cfg.checker

ERROR: bad-successors ;

: check-successors ( bb -- )
    dup successors>> [ predecessors>> member-eq? ] with all?
    [ bad-successors ] unless ;

: check-cfg ( cfg -- )
    [ check-successors ] each-basic-block ;
