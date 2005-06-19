IN: turing
USING: hashtables kernel lists namespaces sequences vectors math
prettyprint io strings words ;

! A turing machine simulator.

TUPLE: state sym dir next ;

! Mapping from symbol/state pairs into new-state tuples
SYMBOL: states

! Halting state
SYMBOL: halt

! This is a simple program that outputs 5 1's
[
    [[ [[ 1 0 ]] << state f 1 1 2 >> ]]
    [[ [[ 2 0 ]] << state f 1 1 3 >> ]]
    [[ [[ 3 0 ]] << state f 1 -1 1 >> ]]
    [[ [[ 1 1 ]] << state f 1 -1 2 >> ]]
    [[ [[ 2 1 ]] << state f 1 -1 3 >> ]]
    [[ [[ 3 1 ]] << state f 1 -1 halt >> ]]
] states set

! Current state
SYMBOL: state

! Initial state
1 state set

! Position of head on tape
SYMBOL: position

! Initial tape position
5 position set

! The tape, a mutable sequence of some kind
SYMBOL: tape

! Initial tape
20 zero-vector tape set

: sym ( -- sym )
    #! Symbol at head position.
    position get tape get nth ;

: set-sym ( sym -- )
    #! Set symbol at head position.
    position get tape get set-nth ;

: next-state ( -- state )
    #! Look up the next state/symbol/direction triplet.
    state get sym cons states get assoc ;

: turing-step ( -- )
    #! Do one step of the turing machine.
    next-state
    dup state-sym set-sym
    dup state-dir position [ + ] change
    state-next state set ;

: c
    #! Print current turing machine state.
    state get .
    tape get .
    2 position get 2 * + CHAR: \s fill write "^" print ;

: n
    #! Do one step and print new state.
    turing-step c ;
