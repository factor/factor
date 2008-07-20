! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math namespaces assocs biassocs accessors
math.order prettyprint.backend parser ;
IN: compiler.cfg.vn.graph

TUPLE: vn n ;

SYMBOL: vn-counter

: next-vn ( -- vn ) vn-counter [ dup 1 + ] change vn boa ;

: VN: scan-word vn boa parsed ; parsing

M: vn <=> [ n>> ] compare ;

M: vn pprint* \ VN: pprint-word n>> pprint* ;

! biassoc mapping expressions to value numbers
SYMBOL: exprs>vns

: expr>vn ( expr -- vn ) exprs>vns get [ drop next-vn ] cache ;

: vn>expr ( vn -- expr ) exprs>vns get value-at ;

SYMBOL: vregs>vns

: vreg>vn ( vreg -- vn ) vregs>vns get at ;

: vn>vreg ( vn -- vreg ) vregs>vns get value-at ;

: set-vn ( vn vreg -- ) vregs>vns get set-at ;

: init-value-graph ( -- )
    0 vn-counter set
    <bihash> exprs>vns set
    <bihash> vregs>vns set ;
