! Copyright (C) 2011 Alex Vondrak.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators.short-circuit
compiler.cfg.def-use compiler.cfg.gvn.avail
compiler.cfg.gvn.expressions compiler.cfg.gvn.graph
compiler.cfg.gvn.rewrite compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.renaming.functor
compiler.cfg.rpo compiler.cfg.utilities kernel namespaces
sequences sequences.deep ;
IN: compiler.cfg.gvn.redundancy-elimination

RENAMING: copy-prop [ vreg>vn ] [ vreg>vn ] [ drop next-vreg ]

: copy-prop ( insn -- insn' )
    dup vreg-insn? [ dup copy-prop-insn-uses ] when ;

GENERIC: update-insn ( insn -- insn/f )

: canonical-leader? ( vreg -- ? ) dup vreg>vn = ;

: check-redundancy? ( insn -- ? )
    defs-vregs {
        [ length 1 = ]
        ! [ first canonical-leader? not ]
    } 1&& ;

: redundant? ( insn -- ? )
    ! [ dst>> ] [ >expr exprs>vns get at ] bi = not ;
    >expr exprs>vns get key? ;

: check-redundancy ( insn -- insn/f )
    dup check-redundancy? [
        dup redundant?
        [ [ dst>> ] [ >expr exprs>vns get at ] bi <copy> ]
        [ make-available ] if
    ] when ;

M: insn update-insn
    dup rewrite [ update-insn ] [ check-redundancy ] ?if ;

M: ##copy update-insn ;

M: array update-insn [ update-insn ] map ;

: (eliminate-redundancies) ( insns -- insns' )
    [ update-insn ] map flatten sift ;

! USING: accessors io prettyprint compiler.cfg compiler.cfg.graphviz
! graphviz.render ;

: eliminate-redundancies ( cfg -- )
    final-iteration? on
    dup compute-avail-sets
    [
        ! "Before:" print
        ! avail-ins get [ [ number>> ] [ keys ] bi* ] assoc-map .
        (eliminate-redundancies)
        ! "After:" print
        ! avail-ins get [ [ number>> ] [ keys ] bi* ] assoc-map .
        ! cfg get cfgviz preview
    ] simple-optimization ;
