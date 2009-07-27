! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs fry kernel namespaces sequences
compiler.cfg.coalescing.state compiler.cfg.renaming compiler.cfg.rpo
disjoint-sets ;
IN: compiler.cfg.coalescing.renaming

: update-congruence-class ( dst assoc disjoint-set -- )
    [ keys swap ] dip
    [ nip add-atoms ]
    [ add-atom drop ]
    [ equate-all-with ] 3tri ;
        
: build-congruence-classes ( -- disjoint-set )
    renaming-sets get
    <disjoint-set> [
        '[
            _ update-congruence-class
        ] assoc-each
    ] keep ;

: compute-renaming ( disjoint-set -- assoc )
    [ parents>> ] keep
    '[ drop dup _ representative ] assoc-map ;

: perform-renaming ( cfg -- )
    build-congruence-classes compute-renaming renamings set
    [
        instructions>> [
            [ rename-insn-defs ]
            [ rename-insn-uses ] bi
        ] each
    ] each-basic-block ;
