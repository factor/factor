! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs fry kernel namespaces sequences
compiler.cfg.ssa.destruction.state compiler.cfg.renaming compiler.cfg.rpo
disjoint-sets ;
IN: compiler.cfg.ssa.destruction.renaming

: build-disjoint-set ( assoc -- disjoint-set )
    <disjoint-set> dup [
        '[
            [ _ add-atom ]
            [ [ drop _ add-atom ] assoc-each ]
            bi*
        ] assoc-each
    ] keep ;

: update-congruence-class ( dst assoc disjoint-set -- )
    [ keys swap ] dip equate-all-with ;
        
: build-congruence-classes ( -- disjoint-set )
    renaming-sets get
    dup build-disjoint-set
    [ '[ _ update-congruence-class ] assoc-each ] keep ;

: compute-renaming ( disjoint-set -- assoc )
    [ parents>> ] keep
    '[ drop dup _ representative ] assoc-map ;

: rename-blocks ( cfg -- )
    [
        instructions>> [
            [ rename-insn-defs ]
            [ rename-insn-uses ] bi
        ] each
    ] each-basic-block ;

: rename-copies ( -- )
    waiting renamings get '[
        [
            [ _ [ ?at drop ] [ '[ _ ?at drop ] map ] bi-curry bi* ] assoc-map
        ] assoc-map
    ] change ;

: perform-renaming ( cfg -- )
    build-congruence-classes compute-renaming renamings set
    rename-blocks
    rename-copies ;
