! Copyright (C) 2008, 2009 Doug Coleman, Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs kernel regexp.ast regexp.classes
regexp.transition-tables sequences sets vectors ;
IN: regexp.dfa

: find-delta ( states transition nfa -- new-states )
    transitions>> '[ _ swap _ at at ] gather sift ;

:: epsilon-loop ( state table nfa question -- )
    state table at :> old-value
    old-value question 2array <or-class> :> new-question
    new-question old-value = [
        new-question state table set-at
        state nfa transitions>> at
        [ drop tagged-epsilon? ] assoc-filter
        [| trans to |
            to [
                table nfa
                trans tag>> new-question 2array <and-class>
                epsilon-loop
            ] each
        ] assoc-each
    ] unless ;

: epsilon-table ( states nfa -- table )
    [ [ H{ } clone ] dip over ] dip
    '[ _ _ t epsilon-loop ] each ;

: find-epsilon-closure ( states nfa -- dfa-state )
    epsilon-table table>condition ;

: find-closure ( states transition nfa -- new-states )
    [ find-delta ] keep find-epsilon-closure ;

: find-start-state ( nfa -- state )
    [ start-state>> 1array ] keep find-epsilon-closure ;

: find-transitions ( dfa-state nfa -- next-dfa-state )
    transitions>>
    '[ _ at keys [ condition-states ] map concat ] gather
    [ tagged-epsilon? ] reject ;

: add-todo-state ( state visited-states new-states -- )
    2over ?adjoin [ nip push ] [ 3drop ] if ;

: add-todo-states ( state/condition visited-states new-states -- )
    [ condition-states ] 2dip
    '[ _ _ add-todo-state ] each ;

: ensure-state ( key table -- )
    2dup key? [ 2drop ] [ [ H{ } clone ] 2dip set-at ] if ; inline

:: new-transitions ( nfa dfa new-states visited-states -- nfa dfa )
    new-states [ nfa dfa ] [
        pop :> state
        state dfa transitions>> ensure-state
        state nfa find-transitions
        [| trans |
            state trans nfa find-closure :> new-state
            new-state visited-states new-states add-todo-states
            state new-state trans dfa set-transition
        ] each
        nfa dfa new-states visited-states new-transitions
    ] if-empty ;

: set-final-states ( nfa dfa -- )
    [
        [ final-states>> members ]
        [ transitions>> keys ] bi*
        [ intersects? ] with filter
        fast-set
    ] keep final-states<< ;

: initialize-dfa ( nfa -- dfa )
    <transition-table>
        swap find-start-state >>start-state ;

: construct-dfa ( nfa -- dfa )
    dup initialize-dfa
    dup start-state>> condition-states >vector
    HS{ } clone
    new-transitions
    [ set-final-states ] keep ;
