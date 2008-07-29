IN: optimizer.control.tests
USING: tools.test optimizer.control combinators kernel
sequences inference.dataflow math inference classes strings
optimizer ;

: label-is-loop? ( node word -- ? )
    [
        {
            { [ over #label? not ] [ 2drop f ] }
            { [ over #label-word over eq? not ] [ 2drop f ] }
            { [ over #label-loop? not ] [ 2drop f ] }
            [ 2drop t ]
        } cond
    ] curry node-exists? ;

: label-is-not-loop? ( node word -- ? )
    [
        {
            { [ over #label? not ] [ f ] }
            { [ over #label-word over eq? not ] [ f ] }
            { [ over #label-loop? ] [ f ] }
            [ t ]
        } cond 2nip
    ] curry node-exists? ;

: loop-test-1 ( a -- )
    dup [ 1+ loop-test-1 ] [ drop ] if ; inline
                          
[ t ] [
    [ loop-test-1 ] dataflow detect-loops
    \ loop-test-1 label-is-loop?
] unit-test

[ t ] [
    [ loop-test-1 1 2 3 ] dataflow detect-loops
    \ loop-test-1 label-is-loop?
] unit-test

[ t ] [
    [ [ loop-test-1 ] each ] dataflow detect-loops
    \ loop-test-1 label-is-loop?
] unit-test

[ t ] [
    [ [ loop-test-1 ] each ] dataflow detect-loops
    \ (each-integer) label-is-loop?
] unit-test

: loop-test-2 ( a -- )
    dup [ 1+ loop-test-2 1- ] [ drop ] if ; inline

[ t ] [
    [ loop-test-2 ] dataflow detect-loops
    \ loop-test-2 label-is-not-loop?
] unit-test

: loop-test-3 ( a -- )
    dup [ [ loop-test-3 ] each ] [ drop ] if ; inline

[ t ] [
    [ loop-test-3 ] dataflow detect-loops
    \ loop-test-3 label-is-not-loop?
] unit-test

: loop-test-4 ( a -- )
    dup [
        loop-test-4
    ] [
        drop
    ] if ; inline

: find-label ( node -- label )
    dup #label? [ node-successor find-label ] unless ;

: test-loop-exits
    dataflow detect-loops find-label
    dup node-param swap
    [ node-child find-tail find-loop-exits [ class ] map ] keep
    #label-loop? ;

[ { #values } t ] [
    [ loop-test-4 ] test-loop-exits
] unit-test

: loop-test-5 ( a -- )
    dup [
        dup string? [
            loop-test-5
        ] [
            drop
        ] if
    ] [
        drop
    ] if ; inline

[ { #values #values } t ] [
    [ loop-test-5 ] test-loop-exits
] unit-test

: loop-test-6 ( a -- )
    dup [
        dup string? [
            loop-test-6
        ] [
            3 throw
        ] if
    ] [
        drop
    ] if ; inline

[ { #values } t ] [
    [ loop-test-6 ] test-loop-exits
] unit-test

[ f ] [
    [ [ [ ] map ] map ] dataflow detect-loops
    [ dup #label? swap #loop? not and ] node-exists?
] unit-test

: blah f ;

DEFER: a

: b ( -- )
    blah [ b ] [ a ] if ; inline

: a ( -- )
    blah [ b ] [ a ] if ; inline

[ t ] [
    [ a ] dataflow detect-loops
    \ a label-is-loop?
] unit-test

[ t ] [
    [ a ] dataflow detect-loops
    \ b label-is-loop?
] unit-test

[ t ] [
    [ b ] dataflow detect-loops
    \ a label-is-loop?
] unit-test

[ t ] [
    [ a ] dataflow detect-loops
    \ b label-is-loop?
] unit-test

DEFER: a'

: b' ( -- )
    blah [ b' b' ] [ a' ] if ; inline

: a' ( -- )
    blah [ b' ] [ a' ] if ; inline

[ f ] [
    [ a' ] dataflow detect-loops
    \ a' label-is-loop?
] unit-test

[ f ] [
    [ b' ] dataflow detect-loops
    \ b' label-is-loop?
] unit-test

! I used to think this should be f, but doing this on pen and
! paper almost convinced me that a loop conversion here is
! sound. The loop analysis algorithm looks pretty solid -- its
! a standard iterative dataflow problem after all -- so I'm
! tempted to believe the computer here
[ t ] [
    [ b' ] dataflow detect-loops
    \ a' label-is-loop?
] unit-test

[ f ] [
    [ a' ] dataflow detect-loops
    \ b' label-is-loop?
] unit-test
