! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces arrays assocs kernel accessors fry grouping
sorting sets sequences locals
cpu.architecture
sequences.deep
compiler.cfg
compiler.cfg.rpo
compiler.cfg.def-use
compiler.cfg.utilities
compiler.cfg.instructions
compiler.cfg.gvn.alien
compiler.cfg.gvn.comparisons
compiler.cfg.gvn.graph
compiler.cfg.gvn.math
compiler.cfg.gvn.rewrite
compiler.cfg.gvn.slots
compiler.cfg.gvn.misc
compiler.cfg.gvn.expressions ;
IN: compiler.cfg.gvn

GENERIC: process-instruction ( insn -- insn' )

: redundant-instruction ( insn vn -- insn' )
    [ dst>> ] dip [ swap set-vn ] [ <copy> ] 2bi ;

:: useful-instruction ( insn expr -- insn' )
    insn dst>> :> vn
    vn vn set-vn
    vn expr exprs>vns get set-at
    insn vn vns>insns get set-at
    insn ;

: check-redundancy ( insn -- insn' )
    dup >expr dup exprs>vns get at
    [ redundant-instruction ] [ useful-instruction ] ?if ;

M: insn process-instruction
    dup rewrite
    [ process-instruction ]
    [ dup defs-vregs length 1 = [ check-redundancy ] when ] ?if ;

M: ##copy process-instruction
    dup [ src>> vreg>vn ] [ dst>> ] bi set-vn ;

M: array process-instruction
    [ process-instruction ] map ;

: value-numbering-step ( insns -- insns' )
    [ process-instruction ] map flatten ;

: value-numbering-iteration ( cfg -- )
    clear-exprs
    [ value-numbering-step drop ] simple-analysis ;

: identify-redundancies ( cfg -- )
    final-iteration? off
    init-value-graph
    '[
        changed? off
        _ value-numbering-iteration
        changed? get
    ] loop ;

: eliminate-redundancies ( cfg -- )
    final-iteration? on
    clear-exprs
    [ value-numbering-step ] simple-optimization ;

: value-numbering ( cfg -- cfg )
    dup identify-redundancies
    dup eliminate-redundancies
    cfg-changed predecessors-changed ;
