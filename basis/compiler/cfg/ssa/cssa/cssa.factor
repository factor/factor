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

SYMBOLS: edge-copies phi-copies ;

: init-copies ( bb -- )
    V{ } clone phi-copies set
    predecessors>> [ V{ } clone ] H{ } map>assoc edge-copies set ;

:: convert-operand ( src pred rep -- dst )
    rep next-vreg-rep :> dst
    { dst src } pred edge-copies get at push
    dst ;

:: convert-phi ( insn preds -- )
    insn dst>> :> dst
    dst rep-of :> rep
    insn inputs>> :> inputs
    rep next-vreg-rep :> dst'

    { dst dst' } phi-copies get push
    dst' insn dst<<

    preds [| pred |
        pred inputs [ pred rep convert-operand ] change-at
    ] each ;

: insert-edge-copies ( from to copies -- )
    [ ##parallel-copy, ##branch, ] { } make insert-basic-block ;

: insert-all-edge-copies ( bb -- )
    [ edge-copies get ] dip '[
        [ drop ] [ [ _ ] dip insert-edge-copies ] if-empty
    ] assoc-each ;

: phi-copy-insn ( -- insn )
    phi-copies get f \ ##parallel-copy boa ;

: end-of-phis ( insns -- i )
    [ [ ##phi? not ] find drop ] [ length ] bi or ;

: insert-phi-copies ( bb -- )
    [
        [
            [ drop phi-copy-insn ] [ end-of-phis ] [ ] tri insert-nth
        ] change-instructions drop
    ] if-has-phis ;

: insert-copies ( bb -- )
    [ insert-all-edge-copies ] [ insert-phi-copies ] bi ;

: convert-phis ( bb -- )
    [ init-copies ]
    [ dup predecessors>> '[ _ convert-phi ] each-phi ]
    [ insert-copies ]
    tri ;

: construct-cssa ( cfg -- )
    needs-predecessors

    dup [ convert-phis ] each-basic-block

    cfg-changed drop ;
