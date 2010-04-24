! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math namespaces assocs biassocs ;
IN: compiler.cfg.value-numbering.graph

! Value numbers are negative, to catch confusion with vregs
SYMBOL: vn-counter

SYMBOL: input-expr-counter

: next-vn ( -- vn ) vn-counter [ 1 - dup ] change ;

! assoc mapping expressions to value numbers
SYMBOL: exprs>vns

! assoc mapping value numbers to instructions
SYMBOL: vns>insns

: vn>insn ( vn -- insn ) vns>insns get at ;

! biassocs mapping vregs to value numbers, and value numbers to
! their primary vregs
SYMBOL: vregs>vns

: vreg>vn ( vreg -- vn ) vregs>vns get [ drop next-vn ] cache ;

: vn>vreg ( vn -- vreg ) vregs>vns get value-at ;

: set-vn ( vn vreg -- ) vregs>vns get set-at ;

: vreg>insn ( vreg -- insn ) vreg>vn vn>insn ; inline

: init-value-graph ( -- )
    0 vn-counter set
    0 input-expr-counter set
    <bihash> vregs>vns set
    H{ } clone exprs>vns set
    H{ } clone vns>insns set ;
