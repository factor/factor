! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel combinators.short-circuit accessors math sequences
sets assocs compiler.cfg.instructions compiler.cfg.rpo
compiler.cfg.def-use compiler.cfg.linearization
compiler.cfg.utilities compiler.cfg.mr compiler.utilities ;
IN: compiler.cfg.checker

! Check invariants

ERROR: bad-kill-block bb ;

: check-kill-block ( bb -- )
    dup instructions>> dup penultimate ##epilogue? [
        {
            [ length 2 = ]
            [ last { [ ##return? ] [ ##callback-return? ] [ ##jump? ] } 1|| ]
        } 1&&
    ] [ last ##branch? ] if
    [ drop ] [ bad-kill-block ] if ;

ERROR: last-insn-not-a-jump bb ;

: check-last-instruction ( bb -- )
    dup instructions>> last {
        [ ##branch? ]
        [ ##dispatch? ]
        [ ##compare-branch? ]
        [ ##compare-imm-branch? ]
        [ ##compare-float-ordered-branch? ]
        [ ##compare-float-unordered-branch? ]
        [ ##fixnum-add? ]
        [ ##fixnum-sub? ]
        [ ##fixnum-mul? ]
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

ERROR: bad-live-in ;

ERROR: undefined-values uses defs ;

: check-mr ( mr -- )
    ! Check that every used register has a definition
    instructions>>
    [ [ uses-vregs ] map concat ]
    [ [ [ temp-vregs ] [ defs-vreg ] bi [ suffix ] when* ] map concat ] bi
    2dup subset? [ 2drop ] [ undefined-values ] if ;

: check-cfg ( cfg -- )
    [ [ check-basic-block ] each-basic-block ]
    [ build-mr check-mr ]
    bi ;
