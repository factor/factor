! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs compiler.cfg compiler.cfg.def-use
compiler.cfg.instructions compiler.cfg.rpo
compiler.cfg.utilities kernel locals namespaces sequences
sequences.deep ;

USE: compiler.cfg.value-numbering.alien
USE: compiler.cfg.value-numbering.comparisons
USE: compiler.cfg.value-numbering.expressions
USE: compiler.cfg.value-numbering.folding
USE: compiler.cfg.value-numbering.graph
USE: compiler.cfg.value-numbering.math
USE: compiler.cfg.value-numbering.misc
USE: compiler.cfg.value-numbering.rewrite
USE: compiler.cfg.value-numbering.slots

IN: compiler.cfg.value-numbering

GENERIC: process-instruction ( insn -- insn' )

: remember-constant ( insn dst -- )
    over literal-insn? constant-instructions get and
    [ constant-instructions get set-at ] [ 2drop ] if ;

: redundant-instruction ( insn vn -- insn' )
    [ dst>> ] dip [ swap set-vn ] [ <copy> ] 2bi ;

:: useful-instruction ( insn expr -- insn' )
    insn dst>> :> vn
    vn vn vregs>vns get set-at
    vn expr exprs>vns get set-at
    insn vn vns>insns get set-at
    insn ;

: check-redundancy ( insn -- insn' )
    dup >expr
    [ exprs>vns get at ] [ redundant-instruction ] [ useful-instruction ] ?if ;

M: insn process-instruction
    [ rewrite ] [ process-instruction ] ?when ;

M: foldable-insn process-instruction
    [ rewrite ]
    [ process-instruction ]
    [ dup defs-vregs length 1 = [ check-redundancy ] when ] ?if ;

M: ##copy process-instruction
    dup [ src>> vreg>insn ] [ dst>> ] bi remember-constant
    dup [ src>> vreg>vn ] [ dst>> ] bi set-vn ;

M: ##load-integer process-instruction
    dup dup dst>> remember-constant call-next-method ;

M: ##load-reference process-instruction
    dup dup dst>> remember-constant call-next-method ;

M: array process-instruction
    [ process-instruction ] map ;

: value-numbering-step ( insns -- insns' )
    init-value-graph
    [ process-instruction ] map flatten ;

: value-numbering ( cfg -- )
    [
        H{ } clone constant-instructions [
            [ value-numbering-step ] simple-optimization
        ] with-variable
    ]
    [ cfg-changed ]
    [ predecessors-changed ] tri ;
