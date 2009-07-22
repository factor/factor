! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel assocs sequences accessors fry combinators grouping sets
arrays vectors locals namespaces make compiler.cfg compiler.cfg.hats
compiler.cfg.instructions compiler.cfg.stack-analysis.state
compiler.cfg.registers compiler.cfg.utilities cpu.architecture ;
IN: compiler.cfg.stack-analysis.merge

: initial-state ( bb states -- state ) 2drop <state> ;

: single-predecessor ( bb states -- state ) nip first clone ;

: save-ds-height ( n -- )
    dup 0 = [ drop ] [ ##inc-d ] if ;

: merge-ds-heights ( state predecessors states -- state )
    [ ds-height>> ] map dup all-equal?
    [ nip first >>ds-height ]
    [ [ '[ _ save-ds-height ] add-instructions ] 2each ] if ;

: save-rs-height ( n -- )
    dup 0 = [ drop ] [ ##inc-r ] if ;

: merge-rs-heights ( state predecessors states -- state )
    [ rs-height>> ] map dup all-equal?
    [ nip first >>rs-height ]
    [ [ '[ _ save-rs-height ] add-instructions ] 2each ] if ;

: assoc-map-keys ( assoc quot -- assoc' )
    '[ _ dip ] assoc-map ; inline

: translate-locs ( assoc state -- assoc' )
    '[ _ translate-loc ] assoc-map-keys ;

: untranslate-locs ( assoc state -- assoc' )
    '[ _ untranslate-loc ] assoc-map-keys ;

: collect-locs ( loc-maps states -- assoc )
    ! assoc maps locs to sequences
    [ untranslate-locs ] 2map
    [ [ keys ] map concat prune ] keep
    '[ dup _ [ at ] with map ] H{ } map>assoc ;

: insert-peek ( predecessor loc state -- vreg )
    '[ _ _ translate-loc ^^peek ] add-instructions ;

SYMBOL: added-phis

: add-phi-later ( inputs -- vreg )
    [ int-regs next-vreg dup ] dip 2array added-phis get push ;

: merge-loc ( predecessors vregs loc state -- vreg )
    ! Insert a ##phi in the current block where the input
    ! is the vreg storing loc from each predecessor block
    '[ [ ] [ _ _ insert-peek ] ?if ] 2map
    dup all-equal? [ first ] [ add-phi-later ] if ;

:: merge-locs ( state predecessors states -- state )
    states [ locs>vregs>> ] map states collect-locs
    [| key value |
        key
        predecessors value key state merge-loc
    ] assoc-map
    state translate-locs
    state (>>locs>vregs)
    state ;

: merge-actual-loc ( vregs -- vreg/f )
    dup all-equal? [ first ] [ drop f ] if ;

:: merge-actual-locs ( state states -- state )
    states [ actual-locs>vregs>> ] map states collect-locs
    [ merge-actual-loc ] assoc-map [ nip ] assoc-filter
    state translate-locs
    state (>>actual-locs>vregs)
    state ;

: merge-changed-locs ( state states -- state )
    [ [ changed-locs>> ] keep untranslate-locs ] map assoc-combine
    over translate-locs
    >>changed-locs ;

:: insert-phis ( bb -- )
    bb predecessors>> :> predecessors
    [
        added-phis get [| dst inputs |
            dst predecessors inputs zip ##phi
        ] assoc-each
    ] V{ } make bb instructions>> over push-all
    bb (>>instructions) ;

:: multiple-predecessors ( bb states -- state )
    states [ not ] any? [
        <state>
        bb add-to-work-list
    ] [
        [
            H{ } clone added-instructions set
            V{ } clone added-phis set
            bb predecessors>> :> predecessors
            state new
            predecessors states merge-ds-heights
            predecessors states merge-rs-heights
            predecessors states merge-locs
            states merge-actual-locs
            states merge-changed-locs
            bb insert-basic-blocks
            bb insert-phis
        ] with-scope
    ] if ;

: merge-states ( bb states -- state )
    dup length {
        { 0 [ initial-state ] }
        { 1 [ single-predecessor ] }
        [ drop multiple-predecessors ]
    } case ;
