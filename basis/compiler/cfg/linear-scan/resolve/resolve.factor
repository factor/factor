! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators
combinators.short-circuit fry kernel locals
make math sequences
compiler.cfg.utilities
compiler.cfg.instructions
compiler.cfg.linear-scan.assignment
compiler.cfg.linear-scan.mapping compiler.cfg.liveness ;
IN: compiler.cfg.linear-scan.resolve

: add-mapping ( from to reg-class -- )
    over spill-slot? [
        pick spill-slot?
        [ memory->memory ]
        [ register->memory ] if
    ] [
        pick spill-slot?
        [ memory->register ]
        [ register->register ] if
    ] if ;

:: resolve-value-data-flow ( bb to vreg -- )
    vreg bb vreg-at-end
    vreg to vreg-at-start
    2dup eq? [ 2drop ] [ vreg reg-class>> add-mapping ] if ;

: compute-mappings ( bb to -- mappings )
    [
        dup live-in keys
        [ resolve-value-data-flow ] with with each
    ] { } make ;

: perform-mappings ( bb to mappings -- )
    dup empty? [ 3drop ] [
        mapping-instructions <simple-block>
        insert-basic-block
    ] if ;

: resolve-edge-data-flow ( bb to -- )
    2dup compute-mappings perform-mappings ;

: resolve-block-data-flow ( bb -- )
    dup successors>> [ resolve-edge-data-flow ] with each ;

: resolve-data-flow ( rpo -- )
    [ resolve-block-data-flow ] each ;
