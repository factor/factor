! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces assocs biassocs classes kernel math accessors
sorting sets sequences fry
compiler.cfg.local
compiler.cfg.liveness
compiler.cfg.renaming
compiler.cfg.value-numbering.graph
compiler.cfg.value-numbering.expressions
compiler.cfg.value-numbering.simplify
compiler.cfg.value-numbering.rewrite ;
IN: compiler.cfg.value-numbering

: number-input-values ( live-in -- )
    [ [ f next-input-expr simplify ] dip set-vn ] each ;

: init-value-numbering ( live-in -- )
    init-value-graph
    init-expressions
    number-input-values ;

: vreg>vreg-mapping ( -- assoc )
    vregs>vns get [ keys ] keep
    '[ dup _ [ at ] [ value-at ] bi ] H{ } map>assoc ;

: rename-uses ( insns -- )
    vreg>vreg-mapping renamings [
        [ rename-insn-uses ] each
    ] with-variable ;

: value-numbering-step ( insns -- insns' )
    [ [ number-values ] [ rewrite ] bi ] map
    dup rename-uses ;

: value-numbering ( cfg -- cfg' )
    [ init-value-numbering ] [ value-numbering-step ] local-optimization ;
