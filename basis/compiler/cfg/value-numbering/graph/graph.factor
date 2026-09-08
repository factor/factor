! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs kernel namespaces ;
IN: compiler.cfg.value-numbering.graph

SYMBOL: input-expr-counter

SYMBOL: vregs>vns

SYMBOL: exprs>vns

SYMBOL: vns>insns

! Constants remain valid across basic blocks in SSA form. Other expressions
! stay local because their definitions may not dominate the current block.
SYMBOL: constant-instructions

: vn>insn ( vn -- insn ) vns>insns get at ;

: vreg>vn ( vreg -- vn ) vregs>vns get [ ] cache ;

: set-vn ( vn vreg -- ) vregs>vns get set-at ;

: vreg>insn ( vreg -- insn )
    dup vreg>vn vn>insn
    [ nip ] [ constant-instructions get at ] if* ;

: init-value-graph ( -- )
    0 input-expr-counter set
    H{ } clone vregs>vns set
    H{ } clone exprs>vns set
    H{ } clone vns>insns set ;
