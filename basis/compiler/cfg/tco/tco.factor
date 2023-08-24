! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators combinators.short-circuit
compiler.cfg compiler.cfg.instructions compiler.cfg.rpo
compiler.cfg.utilities compiler.utilities kernel math namespaces
sequences ;
IN: compiler.cfg.tco

! Tail call optimization.

: return? ( bb -- ? )
    skip-empty-blocks
    instructions>> {
        [ length 3 = ]
        [ first ##safepoint? ]
        [ second ##epilogue? ]
        [ third ##return? ]
    } 1&& ;

: tail-call? ( bb -- ? )
    {
        [ instructions>> { [ length 2 >= ] [ last ##branch? ] } 1&& ]
        [ successors>> first return? ]
    } 1&& ;

: word-tail-call? ( bb -- ? )
    instructions>> penultimate ##call? ;

: convert-tail-call ( ..a bb quot: ( ..a insn -- ..a tail-insn ) -- ..b )
    '[
        instructions>>
        [ pop* ] [ pop ] [ ] tri
        [ [ ##safepoint new-insn ] dip push ]
        [ [ ##epilogue new-insn ] dip push ]
        [ _ dip push ] tri
    ]
    [ successors>> delete-all ]
    bi ; inline

: convert-word-tail-call ( bb -- )
    [ word>> ##jump new-insn ] convert-tail-call ;

: loop-tail-call? ( bb -- ? )
    instructions>> penultimate
    { [ ##call? ] [ word>> cfg get label>> eq? ] } 1&& ;

: convert-loop-tail-call ( bb -- )
    ! If a word calls itself, this becomes a loop in the CFG.
    [
        instructions>> {
            [ pop* ]
            [ pop* ]
            [ [ ##safepoint new-insn ] dip push ]
            [ [ ##branch new-insn ] dip push ]
        } cleave
    ]
    [ successors>> delete-all ]
    [ [ cfg get entry>> successors>> first ] dip successors>> push ]
    tri ;

: optimize-tail-call ( bb -- )
    dup tail-call? [
        {
            { [ dup loop-tail-call? ] [ convert-loop-tail-call ] }
            { [ dup word-tail-call? ] [ convert-word-tail-call ] }
            [ drop ]
        } cond
    ] [ drop ] if ;

: optimize-tail-calls ( cfg -- )
    [ [ optimize-tail-call ] each-basic-block ]
    [ cfg-changed ]
    [ predecessors-changed ] tri ;
