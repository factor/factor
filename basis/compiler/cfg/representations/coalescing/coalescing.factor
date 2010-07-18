! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs compiler.cfg.def-use
compiler.cfg.instructions compiler.cfg.rpo disjoint-sets fry
kernel namespaces sequences ;
IN: compiler.cfg.representations.coalescing

! Find all strongly connected components in the graph where the
! edges are ##phi or ##copy vreg uses
SYMBOL: components

: init-components ( cfg components -- )
    '[
        instructions>> [
            defs-vregs [ _ add-atom ] each
        ] each
    ] each-basic-block ;

GENERIC# visit-insn 1 ( insn disjoint-set -- )

M: ##copy visit-insn
    [ [ dst>> ] [ src>> ] bi ] dip equate ;

M: ##phi visit-insn
    [ [ inputs>> values ] [ dst>> ] bi ] dip equate-all-with ;

M: insn visit-insn 2drop ;

: merge-components ( cfg components -- )
    '[
        instructions>> [
            _ visit-insn
        ] each
    ] each-basic-block ;

: compute-components ( cfg -- )
    <disjoint-set>
    [ init-components ]
    [ merge-components ]
    [ components set drop ] 2tri ;

: vreg>scc ( vreg -- scc )
    components get representative ;
