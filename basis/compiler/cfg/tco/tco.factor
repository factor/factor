! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators.short-circuit kernel math
namespaces sequences fry combinators
compiler.utilities
compiler.cfg
compiler.cfg.rpo
compiler.cfg.hats
compiler.cfg.instructions
compiler.cfg.utilities ;
IN: compiler.cfg.tco

! Tail call optimization. You must run compute-predecessors after this

: return? ( bb -- ? )
    skip-empty-blocks
    instructions>> {
        [ length 2 = ]
        [ first ##epilogue? ]
        [ second ##return? ]
    } 1&& ;

: tail-call? ( bb -- ? )
    {
        [ instructions>> { [ length 2 >= ] [ last ##branch? ] } 1&& ]
        [ successors>> first return? ]
    } 1&& ;

: word-tail-call? ( bb -- ? )
    instructions>> penultimate ##call? ;

: convert-tail-call ( bb quot: ( insn -- tail-insn ) -- )
    '[
        instructions>>
        [ pop* ] [ pop ] [ ] tri
        [ [ \ ##epilogue new-insn ] dip push ]
        [ _ dip push ] bi
    ]
    [ successors>> delete-all ]
    bi ; inline

: convert-word-tail-call ( bb -- )
    [ word>> \ ##jump new-insn ] convert-tail-call ;

: loop-tail-call? ( bb -- ? )
    instructions>> penultimate
    { [ ##call? ] [ word>> cfg get label>> eq? ] } 1&& ;

: convert-loop-tail-call ( bb -- )
    ! If a word calls itself, this becomes a loop in the CFG.
    [ instructions>> [ pop* ] [ pop* ] [ [ \ ##branch new-insn ] dip push ] tri ]
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

: optimize-tail-calls ( cfg -- cfg' )
    dup cfg set
    dup [ optimize-tail-call ] each-basic-block
    cfg-changed ;