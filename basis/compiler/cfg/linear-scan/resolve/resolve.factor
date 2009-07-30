! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators
combinators.short-circuit fry kernel locals namespaces
make math sequences hashtables
compiler.cfg.rpo
compiler.cfg.liveness
compiler.cfg.utilities
compiler.cfg.instructions
compiler.cfg.parallel-copy
compiler.cfg.linear-scan.assignment
compiler.cfg.linear-scan.allocation.state ;
IN: compiler.cfg.linear-scan.resolve

SYMBOL: spill-temps

: spill-temp ( reg-class -- n )
    spill-temps get [ next-spill-slot ] cache ;

: add-mapping ( from to reg-class -- )
    '[ _ 2array ] bi@ 2array , ;

:: resolve-value-data-flow ( bb to vreg -- )
    vreg bb vreg-at-end
    vreg to vreg-at-start
    2dup = [ 2drop ] [ vreg reg-class>> add-mapping ] if ;

: compute-mappings ( bb to -- mappings )
    [
        dup live-in keys
        [ resolve-value-data-flow ] with with each
    ] { } make ;

: memory->register ( from to -- )
    swap [ first2 ] [ first n>> ] bi* _reload ;

: register->memory ( from to -- )
    [ first2 ] [ first n>> ] bi* _spill ;

: temp->register ( from to -- )
    nip [ first ] [ second ] [ second spill-temp ] tri _reload ;

: register->temp ( from to -- )
    drop [ first2 ] [ second spill-temp ] bi _spill ;

: register->register ( from to -- )
    swap [ first ] [ first2 ] bi* _copy ;

SYMBOL: temp

: >insn ( from to -- )
    {
        { [ over temp eq? ] [ temp->register ] }
        { [ dup temp eq? ] [ register->temp ] }
        { [ over first spill-slot? ] [ memory->register ] }
        { [ dup first spill-slot? ] [ register->memory ] }
        [ register->register ]
    } cond ;

: mapping-instructions ( alist -- insns )
    [ swap ] H{ } assoc-map-as
    [ temp [ swap >insn ] parallel-mapping ] { } make ;

: perform-mappings ( bb to mappings -- )
    dup empty? [ 3drop ] [
        mapping-instructions <simple-block>
        insert-basic-block
    ] if ;

: resolve-edge-data-flow ( bb to -- )
    2dup compute-mappings perform-mappings ;

: resolve-block-data-flow ( bb -- )
    dup successors>> [ resolve-edge-data-flow ] with each ;

: resolve-data-flow ( cfg -- )
    H{ } clone spill-temps set
    [ resolve-block-data-flow ] each-basic-block ;
