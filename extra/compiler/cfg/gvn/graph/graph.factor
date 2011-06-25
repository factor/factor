! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors compiler.cfg.gvn.avail kernel math namespaces
assocs ;
IN: compiler.cfg.gvn.graph

SYMBOL: input-expr-counter

! assoc mapping vregs to value numbers
! this is the identity on canonical representatives
SYMBOL: vregs>vns

! assoc mapping expressions to value numbers
SYMBOL: exprs>vns

! assoc mapping value numbers to instructions
SYMBOL: vns>insns

! boolean to track whether vregs>vns changes
SYMBOL: changed?

! boolean to track when it's safe to alter the CFG in a rewrite
! method (i.e., after vregs>vns stops changing)
SYMBOL: final-iteration?

: vn>insn ( vn -- insn ) vns>insns get at ;

: vreg>canon-vn ( vreg -- vn )
    vregs>vns get at ;

: vreg>avail-vn ( vreg -- vn )
    dup vreg>canon-vn dup available? [ nip ] [ drop ] if ;

: vreg>vn ( vreg -- vn )
    final-iteration? get [ vreg>avail-vn ] [ vreg>canon-vn ] if ;

: set-vn ( vn vreg -- )
    vregs>vns get maybe-set-at [ changed? on ] when ;

: vreg>insn ( vreg -- insn ) vreg>vn vn>insn ;

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
