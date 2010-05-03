! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel combinators.short-circuit accessors math sequences
sets assocs compiler.cfg.instructions compiler.cfg.rpo
compiler.cfg.def-use compiler.cfg.linearization
compiler.cfg.utilities compiler.cfg.finalization
compiler.utilities ;
IN: compiler.cfg.checker

! Check invariants

ERROR: bad-kill-block bb ;

: check-kill-block ( bb -- )
    dup instructions>> dup penultimate ##epilogue? [
        {
            [ length 2 = ]
            [ last { [ ##return? ] [ ##jump? ] } 1|| ]
        } 1&&
    ] [ last ##branch? ] if
    [ drop ] [ bad-kill-block ] if ;

ERROR: last-insn-not-a-jump bb ;

: check-last-instruction ( bb -- )
    dup instructions>> last {
        [ ##branch? ]
        [ ##dispatch? ]
        [ conditional-branch-insn? ]
        [ ##no-tco? ]
    } 1|| [ drop ] [ last-insn-not-a-jump ] if ;

ERROR: bad-kill-insn bb ;

: check-kill-instructions ( bb -- )
    dup instructions>> [ kill-vreg-insn? ] any?
    [ bad-kill-insn ] [ drop ] if ;

: check-normal-block ( bb -- )
    [ check-last-instruction ]
    [ check-kill-instructions ]
    bi ;

ERROR: bad-successors ;

: check-successors ( bb -- )
    dup successors>> [ predecessors>> member-eq? ] with all?
    [ bad-successors ] unless ;

: check-basic-block ( bb -- )
    [ dup kill-block? [ check-kill-block ] [ check-normal-block ] if ]
    [ check-successors ]
    bi ;

: check-cfg ( cfg -- )
    [ check-basic-block ] each-basic-block ;
