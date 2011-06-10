! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math namespaces assocs ;
IN: compiler.cfg.gvn.graph

SYMBOL: input-expr-counter

! assoc mapping vregs to *optimistic* value numbers
! initialized per iteration of global value numbering
! this is the identity on canonical representatives
SYMBOL: vregs>vns

! assoc mapping expressions to value numbers
SYMBOL: exprs>vns

! assoc mapping value numbers to instructions
SYMBOL: vns>insns

! assoc mapping vregs to value numbers
! once this stops changing, we know the value numbers are sound
SYMBOL: valid-vns

! boolean to track whether valid-vns changes
SYMBOL: changed?

: vn>insn ( vn -- insn ) vns>insns get at ;

: vreg>vn ( vreg -- vn ) valid-vns get at ;

: optimistic-vn ( default-vn vreg -- vn )
    vregs>vns get ?at
    [ nip ]
    [ dupd vregs>vns get set-at ] if ;

: set-vn ( default-vn vreg -- )
    [ optimistic-vn ] keep
    valid-vns get maybe-set-at [ changed? on ] when ;

: vreg>insn ( vreg -- insn ) vreg>vn vn>insn ;

: clear-optimistic-value-graph ( -- )
    vregs>vns get clear-assoc
    exprs>vns get clear-assoc
    vns>insns get clear-assoc ;

: init-value-graph ( -- )
    0 input-expr-counter set
    H{ } clone valid-vns set
    H{ } clone vregs>vns set
    H{ } clone exprs>vns set
    H{ } clone vns>insns set ;
