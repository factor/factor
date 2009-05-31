! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel compiler.cfg.instructions compiler.cfg.rpo
compiler.cfg.def-use compiler.cfg.linearization compiler.cfg.liveness
combinators.short-circuit accessors math sequences sets assocs ;
IN: compiler.cfg.checker

ERROR: last-insn-not-a-jump insn ;

: check-last-instruction ( bb -- )
    peek dup {
        [ ##branch? ]
        [ ##dispatch? ]
        [ ##conditional-branch? ]
        [ ##compare-imm-branch? ]
        [ ##return? ]
        [ ##callback-return? ]
        [ ##jump? ]
        [ ##call? ]
    } 1|| [ drop ] [ last-insn-not-a-jump ] if ;

ERROR: bad-loop-entry ;

: check-loop-entry ( bb -- )
    dup length 2 >= [
        2 head* [ ##loop-entry? ] any?
        [ bad-loop-entry ] when
    ] [ drop ] if ;

ERROR: bad-successors ;

: check-successors ( bb -- )
    dup successors>> [ predecessors>> memq? ] with all?
    [ bad-successors ] unless ;

: check-basic-block ( bb -- )
    [ instructions>> check-last-instruction ]
    [ instructions>> check-loop-entry ]
    [ check-successors ]
    tri ;

ERROR: bad-live-in ;

ERROR: undefined-values uses defs ;

: check-mr ( mr -- )
    ! Check that every used register has a definition
    instructions>>
    [ [ uses-vregs ] map concat ]
    [ [ [ defs-vregs ] [ temp-vregs ] bi append ] map concat ] bi
    2dup subset? [ 2drop ] [ undefined-values ] if ;

: check-cfg ( cfg -- )
    compute-liveness
    [ entry>> live-in assoc-empty? [ bad-live-in ] unless ]
    [ [ check-basic-block ] each-basic-block ]
    [ flatten-cfg check-mr ]
    tri ;
