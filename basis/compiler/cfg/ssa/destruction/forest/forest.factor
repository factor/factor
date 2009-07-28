! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs fry kernel math math.order
namespaces sequences sorting vectors compiler.cfg.def-use
compiler.cfg.dominance compiler.cfg.registers ;
IN: compiler.cfg.ssa.destruction.forest

TUPLE: dom-forest-node vreg bb children ;

<PRIVATE

: sort-vregs-by-bb ( vregs -- alist )
    defs get
    '[ dup _ at ] { } map>assoc
    [ [ second pre-of ] compare ] sort ;

: <dom-forest-node> ( vreg bb parent -- node )
    [ V{ } clone dom-forest-node boa dup ] dip children>> push ;

: <virtual-root> ( -- node )
    f f V{ } clone dom-forest-node boa ;

: find-parent ( pre stack -- parent )
    2dup last vreg>> def-of maxpre-of > [
        dup pop* find-parent
    ] [ nip last ] if ;

: (compute-dom-forest) ( vreg bb stack -- )
    [ dup pre-of ] dip [ find-parent <dom-forest-node> ] keep push ;

PRIVATE>

: compute-dom-forest ( vregs -- forest )
    <virtual-root> [
        1vector
        [ sort-vregs-by-bb ] dip
        '[ _ (compute-dom-forest) ] assoc-each
    ] keep children>> ;
