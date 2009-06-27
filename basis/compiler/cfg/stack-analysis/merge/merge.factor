! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel assocs sequences accessors fry combinators grouping
sets locals compiler.cfg compiler.cfg.hats compiler.cfg.instructions
compiler.cfg.stack-analysis.state ;
IN: compiler.cfg.stack-analysis.merge

! XXX critical edges

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

: assoc-map-values ( assoc quot -- assoc' )
    '[ _ dip ] assoc-map ; inline

: translate-locs ( assoc state -- assoc' )
    '[ _ translate-loc ] assoc-map-values ;

: untranslate-locs ( assoc state -- assoc' )
    '[ _ untranslate-loc ] assoc-map-values ;

: collect-locs ( loc-maps states -- assoc )
    ! assoc maps locs to sequences of vregs
    [ untranslate-locs ] 2map
    [ [ keys ] map concat prune ] keep
    '[ dup _ [ at ] with map ] H{ } map>assoc ;

: insert-peek ( predecessor state loc -- vreg )
    '[ _ _ swap translate-loc ^^peek ] add-instructions ;

: merge-loc ( predecessors states vregs loc -- vreg )
    ! Insert a ##phi in the current block where the input
    ! is the vreg storing loc from each predecessor block
    '[ dup [ 2nip ] [ drop _ insert-peek ] if ] 3map
    dup all-equal? [ first ] [ ^^phi ] if ;

:: merge-locs ( state predecessors states -- state )
    states [ locs>vregs>> ] map states collect-locs
    [| key value |
        key
        predecessors states value key merge-loc
    ] assoc-map
    state translate-locs
    state (>>locs>vregs)
    state ;

: merge-actual-loc ( vregs -- vreg/f )
    dup all-equal? [ first ] [ drop f ] if ;

: merge-actual-locs ( state states -- state )
    [ [ actual-locs>vregs>> ] map ] keep collect-locs
    [ merge-actual-loc ] assoc-map [ nip ] assoc-filter
    over translate-locs
    >>actual-locs>vregs ;

: merge-changed-locs ( state states -- state )
    [ changed-locs>> ] map assoc-combine >>changed-locs ;

ERROR: cannot-merge-poisoned states ;

: multiple-predecessors ( bb states -- state )
    dup [ not ] any? [
        2drop <state>
    ] [
        dup [ poisoned?>> ] any? [
            cannot-merge-poisoned
        ] [
            [ state new ] 2dip
            [ predecessors>> ] dip
            {
                [ merge-ds-heights ]
                [ merge-rs-heights ]
                [ merge-locs ]
                [ nip merge-actual-locs ]
                [ nip merge-changed-locs ]
            } 2cleave
        ] if
    ] if ;

: merge-states ( bb states -- state )
    ! If any states are poisoned, save all registers
    ! to the stack in each branch
    dup length {
        { 0 [ initial-state ] }
        { 1 [ single-predecessor ] }
        [ drop multiple-predecessors ]
    } case ;
