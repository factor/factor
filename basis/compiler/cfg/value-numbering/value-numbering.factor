! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces assocs kernel accessors
sorting sets sequences
compiler.cfg
compiler.cfg.rpo
compiler.cfg.instructions
compiler.cfg.value-numbering.graph
compiler.cfg.value-numbering.expressions
compiler.cfg.value-numbering.simplify
compiler.cfg.value-numbering.rewrite ;
IN: compiler.cfg.value-numbering

! Local value numbering. Predecessors must be recomputed after this
: >copy ( insn -- insn/##copy )
    dup dst>> dup vreg>vn vn>vreg
    2dup eq? [ 2drop ] [ \ ##copy new-insn nip ] if ;

: rewrite-loop ( insn -- insn' )
    dup rewrite [ rewrite-loop ] [ ] ?if ;

GENERIC: process-instruction ( insn -- insn' )

M: ##flushable process-instruction
    dup rewrite
    [ process-instruction ]
    [ dup number-values >copy ] ?if ;

M: insn process-instruction
    dup rewrite
    [ process-instruction ] [ ] ?if ;

: value-numbering-step ( insns -- insns' )
    init-value-graph
    init-expressions
    [ process-instruction ] map ;

: value-numbering ( cfg -- cfg' )
    [ value-numbering-step ] local-optimization cfg-changed ;
