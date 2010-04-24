! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces assocs kernel accessors
sorting sets sequences arrays
cpu.architecture
sequences.deep
compiler.cfg
compiler.cfg.rpo
compiler.cfg.def-use
compiler.cfg.utilities
compiler.cfg.instructions
compiler.cfg.value-numbering.alien
compiler.cfg.value-numbering.comparisons
compiler.cfg.value-numbering.expressions
compiler.cfg.value-numbering.graph
compiler.cfg.value-numbering.math
compiler.cfg.value-numbering.rewrite
compiler.cfg.value-numbering.slots ;
IN: compiler.cfg.value-numbering

: >copy ( insn vn dst -- insn/##copy )
    swap vn>vreg 2dup eq? [ 2drop ] [ <copy> nip ] if ;

GENERIC: process-instruction ( insn -- insn' )

M: insn process-instruction
    dup rewrite
    [ process-instruction ]
    [
        dup defs-vreg [
            dup [ >expr expr>vn ] [ dst>> ] bi
            [ set-vn drop ]
            [ >copy ]
            3bi
        ] when
    ] ?if ;

M: ##copy process-instruction
    dup [ src>> vreg>vn ] [ dst>> ] bi set-vn ;

M: array process-instruction
    [ process-instruction ] map ;

: value-numbering-step ( insns -- insns' )
    init-value-graph
    [ process-instruction ] map flatten ;

: value-numbering ( cfg -- cfg' )
    [ value-numbering-step ] local-optimization

    cfg-changed predecessors-changed ;
