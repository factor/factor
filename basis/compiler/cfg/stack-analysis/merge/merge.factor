! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel assocs sequences accessors fry combinators grouping
sets compiler.cfg compiler.cfg.hats
compiler.cfg.stack-analysis.state ;
IN: compiler.cfg.stack-analysis.merge

: initial-state ( bb states -- state ) 2drop <state> ;

: single-predecessor ( bb states -- state ) nip first clone ;

ERROR: must-equal-failed seq ;

: must-equal ( seq -- elt )
    dup all-equal? [ first ] [ must-equal-failed ] if ;

: merge-heights ( state predecessors states -- state )
    nip
    [ [ ds-height>> ] map must-equal >>ds-height ]
    [ [ rs-height>> ] map must-equal >>rs-height ] bi ;

: insert-peek ( predecessor loc -- vreg )
    ! XXX critical edges
    '[ _ ^^peek ] add-instructions ;

: merge-loc ( predecessors locs>vregs loc -- vreg )
    ! Insert a ##phi in the current block where the input
    ! is the vreg storing loc from each predecessor block
    [ '[ [ _ ] dip at ] map ] keep
    '[ [ ] [ _ insert-peek ] ?if ] 2map
    dup all-equal? [ first ] [ ^^phi ] if ;

: (merge-locs) ( predecessors assocs -- assoc )
    dup [ keys ] map concat prune
    [ [ 2nip ] [ merge-loc ] 3bi ] with with
    H{ } map>assoc ;

: merge-locs ( state predecessors states -- state )
    [ locs>vregs>> ] map (merge-locs) >>locs>vregs ;

: merge-actual-loc ( locs>vregs loc -- vreg )
    '[ [ _ ] dip at ] map
    dup all-equal? [ first ] [ drop f ] if ;

: merge-actual-locs ( state predecessors states -- state )
    nip
    [ actual-locs>vregs>> ] map
    dup [ keys ] map concat prune
    [ [ nip ] [ merge-actual-loc ] 2bi ] with
    H{ } map>assoc
    [ nip ] assoc-filter
    >>actual-locs>vregs ;

: merge-changed-locs ( state predecessors states -- state )
    nip [ changed-locs>> ] map assoc-combine >>changed-locs ;

ERROR: cannot-merge-poisoned states ;

: multiple-predecessors ( bb states -- state )
    dup [ not ] any? [
        [ <state> ] 2dip
        sift merge-heights
    ] [
        dup [ poisoned?>> ] any? [
            cannot-merge-poisoned
        ] [
            [ state new ] 2dip
            [ predecessors>> ] dip
            {
                [ merge-locs ]
                [ merge-actual-locs ]
                [ merge-heights ]
                [ merge-changed-locs ]
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