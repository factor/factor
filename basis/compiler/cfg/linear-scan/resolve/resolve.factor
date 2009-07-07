! Copyright (C) 2009 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes.parser classes.tuple
combinators combinators.short-circuit fry hashtables kernel locals
make math math.order namespaces sequences sets words parser
compiler.cfg.instructions compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.assignment compiler.cfg.liveness ;
IN: compiler.cfg.linear-scan.resolve

SYMBOL: spill-temps

: spill-temp ( reg-class -- n )
    spill-temps get [ next-spill-slot ] cache ;

<<

TUPLE: operation from to reg-class ;

SYNTAX: OPERATION:
    CREATE-CLASS dup save-location
    [ operation { } define-tuple-class ]
    [ dup '[ _ boa , ] (( from to reg-class -- )) define-declared ] bi ;

>>

OPERATION: register->memory
OPERATION: memory->register
OPERATION: register->register

! This should never come up because of how spill slots are assigned,
! so make it an error.
: memory->memory ( from to reg-class -- ) drop [ n>> ] bi@ assert= ;

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

GENERIC: >insn ( operation -- )

M: register->memory >insn
    [ from>> ] [ reg-class>> ] [ to>> n>> ] tri _spill ;

M: memory->register >insn
    [ to>> ] [ reg-class>> ] [ from>> n>> ] tri  _reload ;

M: register->register >insn
    [ to>> ] [ from>> ] [ reg-class>> ] tri _copy ;

SYMBOL: froms
SYMBOL: tos

SINGLETONS: memory register ;

: from-loc ( operation -- obj ) from>> spill-slot? memory register ? ;

: to-loc ( operation -- obj ) to>> spill-slot? memory register ? ;

: from-reg ( operation -- seq )
    [ from-loc ] [ from>> ] [ reg-class>> ] tri 3array ;

: to-reg ( operation -- seq )
    [ to-loc ] [ to>> ] [ reg-class>> ] tri 3array ;

: start? ( operations -- pair )
    from-reg tos get key? not ;

: independent-assignment? ( operations -- pair )
    to-reg froms get key? not ;

: set-tos/froms ( operations -- )
    [ [ [ from-reg ] keep ] H{ } map>assoc froms set ]
    [ [ [ to-reg ] keep ] H{ } map>assoc tos set ]
    bi ;

:: (trace-chain) ( obj hashtable -- )
    obj to-reg froms get at* [
        dup ,
        obj over hashtable clone [ maybe-set-at ] keep swap
        [ (trace-chain) ] [ 2drop ] if
    ] [
        drop
    ] if ;

: trace-chain ( obj -- seq )
    [
        dup ,
        dup dup associate (trace-chain)
    ] { } make prune reverse ;

: trace-chains ( seq -- seq' )
    [ trace-chain ] map concat ;

ERROR: resolve-error ;

: split-cycle ( operations -- chain spilled-operation )
    unclip [
        [ set-tos/froms ]
        [
            [ start? ] find nip
            [ resolve-error ] unless* trace-chain
        ] bi
    ] dip ;

: break-cycle-n ( operations -- operations' )
    split-cycle [
        [ from>> ]
        [ reg-class>> spill-temp <spill-slot> ]
        [ reg-class>> ]
        tri \ register->memory boa
    ] [
        [ reg-class>> spill-temp <spill-slot> ]
        [ to>> ]
        [ reg-class>> ]
        tri \ memory->register boa
    ] bi [ 1array ] bi@ surround ;

: break-cycle ( operations -- operations' )
    dup length {
        { 1 [ ] }
        [ drop break-cycle-n ]
    } case ;

: (group-cycles) ( seq -- )
    [
        dup set-tos/froms
        unclip trace-chain
        [ diff ] keep , (group-cycles)
    ] unless-empty ;

: group-cycles ( seq -- seqs )
    [ (group-cycles) ] { } make ;

: remove-dead-mappings ( seq -- seq' )
    prune [ [ from-reg ] [ to-reg ] bi = not ] filter ;

: parallel-mappings ( operations -- seq )
    [
        [ independent-assignment? not ] partition %
        [ start? not ] partition
        [ trace-chain ] map concat dup %
        diff group-cycles [ break-cycle ] map concat %
    ] { } make remove-dead-mappings ;

: mapping-instructions ( mappings -- insns )
    [
        [ set-tos/froms ] [ parallel-mappings ] bi
        [ [ >insn ] each ] { } make
    ] with-scope ;

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
    H{ } clone spill-temps set
    [ resolve-block-data-flow ] each ;
