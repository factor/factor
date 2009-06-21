! Copyright (C) 2009 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel math namespaces sequences
classes.tuple classes.parser parser fry words make arrays
combinators compiler.cfg.linear-scan.live-intervals
compiler.cfg.liveness compiler.cfg.instructions ;
IN: compiler.cfg.linear-scan.resolve

<<

TUPLE: operation from to reg-class ;

SYNTAX: OPERATION:
    CREATE-CLASS dup save-location
    [ operation { } define-tuple-class ]
    [
        [ scan-word scan-word ] keep
        '[
            [ [ _ execute ] [ _ execute ] bi* ]
            [ vreg>> reg-class>> ]
            bi _ boa ,
        ] (( from to -- )) define-declared
    ] bi ;

>>

OPERATION: memory->memory spill-to>> reload-from>>
OPERATION: register->memory reg>> reload-from>>
OPERATION: memory->register spill-to>> reg>>
OPERATION: register->register reg>> reg>>

: add-mapping ( from to -- )
    dup reload-from>> [
        over spill-to>> [ memory->memory ] [ register->memory ] if
    ] [
        over spill-to>> [ memory->register ] [ register->register ] if
    ] if ;

: resolve-value-data-flow ( bb to vreg -- )
    live-intervals get at
    [ [ block-to ] dip child-interval-at ]
    [ [ block-from ] dip child-interval-at ]
    bi-curry bi* 2dup eq? [ 2drop ] [ add-mapping ] if ;

: compute-mappings ( bb to -- mappings )
    [
        dup live-in keys
        [ resolve-value-data-flow ] with with each
    ] { } make ;

GENERIC: >insn ( operation -- )

: >operation< ( operation -- from to reg-class )
    [ from>> ] [ to>> ] [ reg-class>> ] tri ; inline

M: memory->memory >insn
    [ from>> ] [ to>> ] bi = [ "Not allowed" throw ] unless ;

M: register->memory >insn
    [ from>> ] [ reg-class>> ] [ to>> ] tri _spill ;

M: memory->register >insn
    [ to>> ] [ reg-class>> ] [ from>> ] tri _reload ;

M: register->register >insn
    [ to>> ] [ from>> ] [ reg-class>> ] tri _copy ;

: mapping-instructions ( mappings -- insns )
    [ [ >insn ] each ] { } make ;

: fork? ( from to -- ? )
    [ successors>> length 1 >= ]
    [ predecessors>> length 1 = ] bi* and ; inline

: insert-position/fork ( from to -- before after )
    nip instructions>> [ >array ] [ dup delete-all ] bi swap ;

: join? ( from to -- ? )
    [ successors>> length 1 = ]
    [ predecessors>> length 1 >= ] bi* and ; inline

: insert-position/join ( from to -- before after )
    drop instructions>> { } ;

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