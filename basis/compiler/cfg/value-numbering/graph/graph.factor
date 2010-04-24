! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math namespaces assocs biassocs ;
IN: compiler.cfg.value-numbering.graph

! Value numbers are negative, to catch confusion with vregs
SYMBOL: vn-counter

: next-vn ( -- vn ) vn-counter [ 1 - dup ] change ;

! biassoc mapping expressions to value numbers
SYMBOL: exprs>vns

TUPLE: expr ;

: expr>vn ( expr -- vn ) exprs>vns get [ drop next-vn ] cache ;

: vn>expr ( vn -- expr ) exprs>vns get value-at ;

! Expressions whose values are inputs to the basic block.
TUPLE: input-expr < expr n ;

SYMBOL: input-expr-counter

: next-input-expr ( -- expr )
    input-expr-counter counter input-expr boa ;

SYMBOL: vregs>vns

: vreg>vn ( vreg -- vn )
    vregs>vns get [ drop next-input-expr expr>vn ] cache ;

: vn>vreg ( vn -- vreg ) vregs>vns get value-at ;

: set-vn ( vn vreg -- ) vregs>vns get set-at ;

: vreg>expr ( vreg -- expr ) vreg>vn vn>expr ; inline

: init-value-graph ( -- )
    0 vn-counter set
    0 input-expr-counter set
    <bihash> exprs>vns set
    <bihash> vregs>vns set ;
