! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math namespaces assocs ;
IN: compiler.cfg.gvn.graph

SYMBOL: input-expr-counter

! assoc mapping vregs to value numbers
! this is the identity on canonical representatives
SYMBOL: vregs>vns

! assoc mapping expressions to value numbers
SYMBOL: exprs>vns

! assoc mapping value numbers to instructions
SYMBOL: vns>insns

! assoc mapping basic blocks to the set of value numbers that
! are defined in the block
SYMBOL: bbs>defns

! boolean to track whether vregs>vns changes
SYMBOL: changed?

: vn>insn ( vn -- insn ) vns>insns get at ;

: vreg>vn ( vreg -- vn ) vregs>vns get at ;

: set-vn ( vn vreg -- )
    vregs>vns get maybe-set-at [ changed? on ] when ;

: vreg>insn ( vreg -- insn ) vreg>vn vn>insn ;

: defined ( bb -- vns ) bbs>defns get at ;

: clear-exprs ( -- )
    exprs>vns get clear-assoc
    vns>insns get clear-assoc
    bbs>defns get clear-assoc ;

: init-value-graph ( -- )
    0 input-expr-counter set
    H{ } clone vregs>vns set
    H{ } clone exprs>vns set
    H{ } clone vns>insns set
    H{ } clone bbs>defns set ;
