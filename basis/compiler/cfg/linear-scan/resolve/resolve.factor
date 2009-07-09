! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators
combinators.short-circuit fry kernel locals
make math sequences
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

: fork? ( from to -- ? )
    {
        [ drop successors>> length 1 >= ]
        [ nip predecessors>> length 1 = ]
    } 2&& ; inline

: insert-position/fork ( from to -- before after )
    nip instructions>> [ >array ] [ dup delete-all ] bi swap ;

: join? ( from to -- ? )
    {
        [ drop successors>> length 1 = ]
        [ nip predecessors>> length 1 >= ]
    } 2&& ; inline

: insert-position/join ( from to -- before after )
    drop instructions>> dup pop 1array ;

: insert-position ( bb to -- before after )
    {
        { [ 2dup fork? ] [ insert-position/fork ] }
        { [ 2dup join? ] [ insert-position/join ] }
    } cond ;

: 3append-here ( seq2 seq1 seq3 -- )
    #! Mutate seq1
    swap '[ _ push-all ] bi@ ;

: perform-mappings ( mappings bb to -- )
    pick empty? [ 3drop ] [
        [ mapping-instructions ] 2dip
        insert-position 3append-here
    ] if ;

: resolve-edge-data-flow ( bb to -- )
    [ compute-mappings ] [ perform-mappings ] 2bi ;

: resolve-block-data-flow ( bb -- )
    dup successors>> [ resolve-edge-data-flow ] with each ;

: resolve-data-flow ( rpo -- )
    [ resolve-block-data-flow ] each ;
