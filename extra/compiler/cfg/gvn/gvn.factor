! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces arrays assocs hashtables kernel accessors fry
grouping sorting sets sequences locals
cpu.architecture
sequences.deep
compiler.cfg
compiler.cfg.rpo
compiler.cfg.def-use
compiler.cfg.utilities
compiler.cfg.instructions
compiler.cfg.predecessors
compiler.cfg.gvn.alien
compiler.cfg.gvn.avail
compiler.cfg.gvn.comparisons
compiler.cfg.gvn.graph
compiler.cfg.gvn.math
compiler.cfg.gvn.rewrite
compiler.cfg.gvn.slots
compiler.cfg.gvn.misc
compiler.cfg.gvn.expressions ;
IN: compiler.cfg.gvn

GENERIC: simplify ( insn -- insn' )

M: insn simplify dup rewrite [ simplify ] [ ] ?if ;
M: array simplify [ simplify ] map ;
M: ##copy simplify ;

GENERIC: value-number ( insn -- )

M: alien-call-insn value-number drop ;
M: ##callback-inputs value-number drop ;
M: ##copy value-number [ src>> vreg>vn ] [ dst>> ] bi set-vn ;

: redundant-instruction ( insn vn -- )
    swap dst>> set-vn ;

:: useful-instruction ( insn expr -- )
    insn dst>> :> vn
    vn vn set-vn
    vn expr exprs>vns get set-at
    insn vn vns>insns get set-at ;

M: insn value-number
    dup defs-vregs length 1 = [
        dup >expr dup exprs>vns get at
        [ redundant-instruction ] [ useful-instruction ] ?if
    ] [ drop ] if ;

: value-numbering-step ( insns -- )
    [ simplify ] map flatten [ value-number ] each ;

: value-numbering-iteration ( cfg -- )
    clear-exprs [ value-numbering-step ] simple-analysis ;

: determine-value-numbers ( cfg -- )
    final-iteration? off
    init-value-graph
    '[
        changed? off
        _ value-numbering-iteration
        changed? get
    ] loop ;

: value-numbering ( cfg -- cfg )
    needs-predecessors
    dup determine-value-numbers

    cfg-changed predecessors-changed ;
