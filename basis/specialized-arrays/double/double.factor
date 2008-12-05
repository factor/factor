USE: specialized-arrays.functor
IN: specialized-arrays.double

<< "double" define-array >>

! Specializer hints. These should really be generalized, and placed
! somewhere else
USING: hints math.vectors arrays kernel math accessors sequences ;

HINTS: <double-array> { 2 } { 3 } ;

HINTS: (double-array) { 2 } { 3 } ;

HINTS: vneg { array } { double-array } ;
HINTS: v*n { array object } { double-array float } ;
HINTS: n*v { array object } { float double-array } ;
HINTS: v/n { array object } { double-array float } ;
HINTS: n/v { object array } { float double-array } ;
HINTS: v+ { array array } { double-array double-array } ;
HINTS: v- { array array } { double-array double-array } ;
HINTS: v* { array array } { double-array double-array } ;
HINTS: v/ { array array } { double-array double-array } ;
HINTS: vmax { array array } { double-array double-array } ;
HINTS: vmin { array array } { double-array double-array } ;
HINTS: v. { array array } { double-array double-array } ;
HINTS: norm-sq { array } { double-array } ;
HINTS: norm { array } { double-array } ;
HINTS: normalize { array } { double-array } ;
HINTS: distance { array array } { double-array double-array } ;

! Type functions
USING: words classes.algebra compiler.tree.propagation.info
math.intervals ;

{ v+ v- v* v/ vmax vmin } [
    [
        [ class>> double-array class<= ] both?
        double-array object ? <class-info>
    ] "outputs" set-word-prop
] each

{ n*v n/v } [
    [
        nip class>> double-array class<= double-array object ? <class-info>
    ] "outputs" set-word-prop
] each

{ v*n v/n } [
    [
        drop class>> double-array class<= double-array object ? <class-info>
    ] "outputs" set-word-prop
] each

{ vneg normalize } [
    [
        class>> double-array class<= double-array object ? <class-info>
    ] "outputs" set-word-prop
] each

\ norm-sq [
    class>> double-array class<= [ float 0. 1/0. [a,b] <class/interval-info> ] [ object-info ] if
] "outputs" set-word-prop

\ v. [
    [ class>> double-array class<= ] both?
    float object ? <class-info>
] "outputs" set-word-prop

\ distance [
    [ class>> double-array class<= ] both?
    [ float 0. 1/0. [a,b] <class/interval-info> ] [ object-info ] if
] "outputs" set-word-prop
