! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces arrays assocs kernel accessors
sorting sets sequences locals
cpu.architecture
sequences.deep
compiler.cfg
compiler.cfg.rpo
compiler.cfg.def-use
compiler.cfg.utilities
compiler.cfg.instructions
compiler.cfg.value-numbering.alien
compiler.cfg.value-numbering.comparisons
compiler.cfg.value-numbering.graph
compiler.cfg.value-numbering.math
compiler.cfg.value-numbering.rewrite
compiler.cfg.value-numbering.slots
compiler.cfg.value-numbering.misc
compiler.cfg.value-numbering.expressions ;
IN: compiler.cfg.value-numbering

GENERIC: process-instruction ( insn -- insn' )

: redundant-instruction ( insn vn -- insn' )
    [ dst>> ] dip [ swap set-vn ] [ <copy> ] 2bi ;

:: useful-instruction ( insn expr -- insn' )
    insn dst>> :> vn
    vn vn vregs>vns get set-at
    vn expr exprs>vns get set-at
    insn vn vns>insns get set-at
    insn ;

: check-redundancy ( insn -- insn' )
    dup >expr dup exprs>vns get at
    [ redundant-instruction ] [ useful-instruction ] ?if ;

M: insn process-instruction
    dup rewrite
    [ process-instruction ]
    [ dup defs-vreg [ check-redundancy ] when ] ?if ;

M: ##copy process-instruction
    dup [ src>> vreg>vn ] [ dst>> ] bi set-vn ;

M: array process-instruction
    [ process-instruction ] map ;

: value-numbering-step ( insns -- insns' )
    init-value-graph
    [ process-instruction ] map flatten ;

: value-numbering ( cfg -- cfg )
    dup [ value-numbering-step ] simple-optimization

    cfg-changed predecessors-changed ;
