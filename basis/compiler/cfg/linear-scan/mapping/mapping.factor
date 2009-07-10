! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes.parser classes.tuple
combinators compiler.cfg.instructions
compiler.cfg.linear-scan.allocation.state fry hashtables kernel
locals make namespaces parser sequences sets words ;
IN: compiler.cfg.linear-scan.mapping

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
    [ { } ] [
        [
            [ set-tos/froms ] [ parallel-mappings ] bi
            [ [ >insn ] each ] { } make
        ] with-scope
    ] if-empty ;

: init-mapping ( -- )
    H{ } clone spill-temps set ;