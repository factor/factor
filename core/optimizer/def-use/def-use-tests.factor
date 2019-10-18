IN: temporary
USING: inference inference.dataflow optimizer optimizer.def-use
namespaces assocs kernel sequences math tools.test words ;

[ 3 { 1 1 1 } ] [
    [ 1 2 3 ] dataflow compute-def-use
    def-use get values dup length swap [ length ] map
] unit-test

: kill-set ( quot -- seq )
    dataflow compute-def-use dead-literals keys
    [ value-literal ] map ;

: subset? [ member? ] curry all? ;

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

: p1 drop 4 ;
: p2 3drop 1 2 ;
: p3 drop 3 ;

: regression-0
    [ 2drop ] curry* assoc-find ;

[ t ] [
    [ [ 2drop ] curry* assoc-find ] kill-set
    [ 2drop ] swap member?
] unit-test

[ t ] [
    [ [ "x" 2drop ] assoc-find ] kill-set
    [ "x" 2drop ] swap member?
] unit-test

: 2swap ( x y z t -- z t x y )
    rot >r rot r> ; inline

: regression-1
    [ 2swap [ swapd * -rot p2 +@ ] 2keep ] assoc-each ;

[ { t t } ] [
    {
        [ swapd * -rot p2 +@ ]
        [ 2swap [ swapd * -rot p2 +@ ] 2keep ]
    } \ regression-1 word-def kill-set [ member? ] curry map
] unit-test

: regression-2 ( x y -- x.y )
    [ p1 ] 2apply [
        [
            rot
            [ 2swap [ swapd * -rot p2 +@ ] 2keep ]
            assoc-each 2drop
        ] curry* assoc-each
    ] H{ } make-assoc p3 ;

[ { t t t t t } ] [
    {
        [ p1 ]
        [ swapd * -rot p2 +@ ]
        [ 2swap [ swapd * -rot p2 +@ ] 2keep ]
        [
            rot
            [ 2swap [ swapd * -rot p2 +@ ] 2keep ]
            assoc-each 2drop
        ]
        [
            [
                rot
                [ 2swap [ swapd * -rot p2 +@ ] 2keep ]
                assoc-each 2drop
            ] curry* assoc-each
        ]
    }
    \ regression-2 word-def kill-set
    [ member? ] curry map
] unit-test
