IN: temporary
USING: inference optimizer namespaces assocs kernel
sequences math test ;

[ 3 { 1 1 1 } ] [
    [ 1 2 3 ] dataflow compute-def-use
    def-use get values dup length swap [ length ] map
] unit-test

: kill-set ( quot -- seq )
    dataflow compute-def-use dead-literals keys
    [ value-literal ] map ;

: subset? swap [ swap member? ] all-with? ;

: set= 2dup subset? >r swap subset? r> and ;

[ { [ + ] } ] [
    [ [ 1 2 3 ] [ + ] over drop drop ] kill-set
] unit-test

[ { [ + ] } ] [
    [ [ + ] [ 1 2 3 ] over drop nip ] kill-set
] unit-test

[ { [ + ] } ] [
    [ [ + ] dup over 3drop ] kill-set
] unit-test

[ t ] [
    { [ + ] [ - ] }
    [ [ + ] [ - ] [ 1 2 3 ] pick pick 2drop >r 2drop r> ]
    kill-set set=
] unit-test

[ t ] [
    { [ + ] }
    [ [ 1 2 3 ] [ 4 5 6 ] [ + ] pick >r drop r> ]
    kill-set set=
] unit-test

[ t ] [
    [ [ 1 ] [ 2 ] ] [ [ 1 ] [ 2 ] if ] kill-set set=
] unit-test

[ t ] [
    { [ 5 ] [ dup ] }
    [ [ 5 ] [ dup ] if ] kill-set set=
] unit-test

[ t ] [
    [ [ dup ] [ dup ] ]
    [ 5 swap [ dup ] [ dup ] if ]
    kill-set set=
] unit-test

[ t ] [
    [ 5 [ dup ] [ dup ] ]
    [ 5 swap [ dup ] [ dup ] if 2drop ]
    kill-set set=
] unit-test

: literal-kill-test ( a b -- )
    dup [ >r dup slip r> literal-kill-test ] [ 2drop ] if ; inline

[ t ] [
    { [ ] [ >r dup slip r> literal-kill-test ] [ 2drop ] }
    [ [ ] swap literal-kill-test ] kill-set set=
] unit-test
