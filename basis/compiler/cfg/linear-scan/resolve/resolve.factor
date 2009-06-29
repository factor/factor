! Copyright (C) 2009 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes.parser classes.tuple
combinators combinators.short-circuit fry hashtables kernel locals
make math math.order namespaces sequences sets words parser histogram
compiler.cfg.instructions compiler.cfg.linear-scan.live-intervals
compiler.cfg.liveness ;
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

: reload-from ( bb live-interval -- n/f )
    2dup [ block-from ] [ start>> ] bi* =
    [ nip reload-from>> ] [ 2drop f ] if ;

: spill-to ( bb live-interval -- n/f )
    2dup [ block-to ] [ end>> ] bi* =
    [ nip spill-to>> ] [ 2drop f ] if ;

OPERATION: memory->memory spill-to>> reload-from>>
OPERATION: register->memory reg>> reload-from>>
OPERATION: memory->register spill-to>> reg>>
OPERATION: register->register reg>> reg>>

:: add-mapping ( bb1 bb2 li1 li2 -- )
    bb2 li2 reload-from [
        bb1 li1 spill-to
        [ li1 li2 memory->memory ]
        [ li1 li2 register->memory ] if
    ] [
        bb1 li1 spill-to
        [ li1 li2 memory->register ]
        [ li1 li2 register->register ] if
    ] if ;

: resolve-value-data-flow ( bb to vreg -- )
    [ 2dup ] dip
    live-intervals get at
    [ [ block-to ] dip child-interval-at ]
    [ [ block-from ] dip child-interval-at ]
    bi-curry bi* 2dup eq? [ 2drop 2drop ] [ add-mapping ] if ;

: compute-mappings ( bb to -- mappings )
    [
        dup live-in keys
        [ resolve-value-data-flow ] with with each
    ] { } make ;

GENERIC: >insn ( operation -- )

M: memory->memory >insn
    [ from>> ] [ to>> ] bi = [ "Not allowed" throw ] unless ;

M: register->memory >insn
    [ from>> ] [ reg-class>> ] [ to>> ] tri _spill ;

M: memory->register >insn
    [ to>> ] [ reg-class>> ] [ from>> ] tri _reload ;

M: register->register >insn
    [ to>> ] [ from>> ] [ reg-class>> ] tri _copy ;

GENERIC: >collision-table ( operation -- )

M: memory->memory >collision-table
    [ from>> ] [ to>> ] bi = [ "Not allowed" throw ] unless ;

M: register->memory >collision-table
    [ from>> ] [ reg-class>> ] [ to>> ] tri _spill ;

M: memory->register >collision-table
    [ to>> ] [ reg-class>> ] [ from>> ] tri _reload ;

M: register->register >collision-table
    [ to>> ] [ from>> ] [ reg-class>> ] tri _copy ;

SYMBOL: froms
SYMBOL: tos

SINGLETONS: memory register ;

GENERIC: from-loc ( operation -- obj )
M: memory->memory from-loc drop memory ;
M: register->memory from-loc drop register ;
M: memory->register from-loc drop memory ;
M: register->register from-loc drop register ;

GENERIC: to-loc ( operation -- obj )
M: memory->memory to-loc drop memory ;
M: register->memory to-loc drop memory ;
M: memory->register to-loc drop register ;
M: register->register to-loc drop register ;

: from-reg ( operation -- seq )
    [ from-loc ] [ from>> ] [ reg-class>> ] tri 3array ;

: to-reg ( operation -- seq )
    [ to-loc ] [ to>> ] [ reg-class>> ] tri 3array ;

: (trace-chain) ( pair -- )
    to-reg froms get at [
        dup length 1 = [
            first [ , ] [ (trace-chain) ] bi
        ] [
            drop
        ] if
    ] when* ;

: trace-chain ( pair -- seq )
    [ [ , ] [ (trace-chain) ] bi ] { } make reverse ;

: start? ( operations -- pair )
    from-reg tos get key? not ;

: init-temp-spill ( operations -- )
    [ [ to>> ] [ from>> ] bi max ] [ max ] map-reduce
    1 + temp-spill set ;

: set-tos/froms ( operations -- )
    [ [ from-reg ] collect-values froms set ]
    [ [ to-reg ] collect-values tos set ]
    bi ;

: trace-chains ( operations -- operations' )
    [ set-tos/froms ]
    [ [ start? ] filter [ trace-chain ] map concat ] bi ;

: break-cycle-n ( operations -- operations' )
    unclip [ trace-chains ] dip
    [
        [ from>> temp-spill get ]
        [ reg-class>> ] bi \ register->memory boa
    ] [
        [ to>> temp-spill [ get ] [ inc ] bi swap ]
        [ reg-class>> ] bi \ memory->register boa
    ] bi [ 1array ] bi@ surround ;

: break-cycle ( operations -- operations' )
    dup length {
        { 1 [ drop { } ] }
        [ drop break-cycle-n ]
    } case ;

: follow-cycle ( obj -- seq )
   dup dup associate [
        [ to-reg froms get at first dup dup ] dip
        [ maybe-set-at ] keep swap
    ] loop nip keys ;

: (group-cycles) ( seq -- )
    [
        unclip follow-cycle [ diff ] keep , (group-cycles)
    ] unless-empty ;

: group-cycles ( seq -- seqs )
    [ (group-cycles) ] { } make ;

: partition-mappings ( mappings -- no-cycles cycles )
    [ start? not ] partition
    [ trace-chain ] map concat tuck diff ;

: parallel-mappings ( operations -- seq )
    partition-mappings [
        group-cycles [ break-cycle ] map concat append
    ] unless-empty ;

: mapping-instructions ( mappings -- insns )
    [
        [ init-temp-spill ]
        [ set-tos/froms ]
        [ parallel-mappings ] tri
        [ [ >insn ] each ] { } make
    ] with-scope ;

: fork? ( from to -- ? )
    [ successors>> length 1 >= ]
    [ predecessors>> length 1 = ] bi* and ; inline

: insert-position/fork ( from to -- before after )
    nip instructions>> [ >array ] [ dup delete-all ] bi swap ;

: join? ( from to -- ? )
    [ successors>> length 1 = ]
    [ predecessors>> length 1 >= ] bi* and ; inline

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
