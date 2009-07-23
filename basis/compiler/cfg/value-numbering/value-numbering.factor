! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces assocs biassocs classes kernel math accessors
sorting sets sequences fry
compiler.cfg
compiler.cfg.rpo
compiler.cfg.renaming
compiler.cfg.value-numbering.graph
compiler.cfg.value-numbering.expressions
compiler.cfg.value-numbering.simplify
compiler.cfg.value-numbering.rewrite ;
IN: compiler.cfg.value-numbering

! Local value numbering. Predecessors must be recomputed after this
: vreg>vreg-mapping ( -- assoc )
    vregs>vns get [ keys ] keep
    '[ dup _ [ at ] [ value-at ] bi ] H{ } map>assoc ;

: rename-uses ( insns -- )
    vreg>vreg-mapping renamings [
        [ rename-insn-uses ] each
    ] with-variable ;

: value-numbering-step ( insns -- insns' )
    init-value-graph
    init-expressions
    [ rewrite ] map
    dup rename-uses ;

: value-numbering ( cfg -- cfg' )
    [ value-numbering-step ] local-optimization cfg-changed ;
