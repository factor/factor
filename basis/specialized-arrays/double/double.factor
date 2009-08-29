USE: specialized-arrays.functor
IN: specialized-arrays.double

<< "double" define-array >>

! Specializer hints. These should really be generalized, and placed
! somewhere else
USING: hints math.vectors arrays kernel math accessors sequences ;

HINTS: <double-array> { 2 } { 3 } ;

HINTS: (double-array) { 2 } { 3 } ;

! Type functions
USING: words classes.algebra compiler.tree.propagation.info
math.intervals ;

\ norm-sq [
    class>> double-array class<= [ float 0. 1/0. [a,b] <class/interval-info> ] [ object-info ] if
] "outputs" set-word-prop

\ distance [
    [ class>> double-array class<= ] both?
    [ float 0. 1/0. [a,b] <class/interval-info> ] [ object-info ] if
] "outputs" set-word-prop
