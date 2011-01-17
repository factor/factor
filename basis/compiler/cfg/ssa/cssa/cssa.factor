! Copyright (C) 2009, 2011 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel locals fry make namespaces
sequences cpu.architecture
compiler.cfg
compiler.cfg.rpo
compiler.cfg.utilities
compiler.cfg.predecessors
compiler.cfg.registers
compiler.cfg.instructions ;
FROM: assocs => change-at ;
IN: compiler.cfg.ssa.cssa

! Convert SSA to conventional SSA. This pass runs after representation
! selection, so it must keep track of representations when introducing
! new values.

SYMBOL: copies

: init-copies ( bb -- )
    predecessors>> [ V{ } clone ] H{ } map>assoc copies set ;

:: convert-operand ( src pred rep -- dst )
    rep next-vreg-rep :> dst
    { dst src } pred copies get at push
    dst ;

:: convert-phi ( insn preds -- )
    insn dst>> rep-of :> rep
    insn inputs>> :> inputs
    preds [| pred |
        pred inputs [ pred rep convert-operand ] change-at
    ] each ;

: insert-edge-copies ( from to copies -- )
    [ ##parallel-copy ##branch ] { } make insert-basic-block ;

: insert-copies ( bb -- )
    [ copies get ] dip '[
        [ drop ] [ [ _ ] dip insert-edge-copies ] if-empty
    ] assoc-each ;

: convert-phis ( bb -- )
    [ init-copies ]
    [ dup predecessors>> '[ _ convert-phi ] each-phi ]
    [ insert-copies ]
    tri ;

: construct-cssa ( cfg -- )
    needs-predecessors

    dup [ convert-phis ] each-basic-block

    cfg-changed drop ;
