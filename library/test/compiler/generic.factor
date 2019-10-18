IN: scratchpad
USE: compiler
USE: generic
USE: test
USE: math
USE: kernel
USE: words

: single-combination-test
    {
        [ drop ]
        [ drop ]
        [ drop ]
        [ drop ]
        [ drop ]
        [ drop ]
        [ nip  ]
        [ drop ]
        [ drop ]
        [ drop ]
        [ drop ]
        [ drop ]
        [ drop ]
        [ drop ]
        [ drop ]
        [ drop ]
        [ drop ]
    } single-combination ; compiled

[ 2 3 ] [ 2 3 t single-combination-test ] unit-test
[ 2 3 ] [ 2 3 4 single-combination-test ] unit-test
[ 2 f ] [ 2 3 f single-combination-test ] unit-test

: single-combination-literal-test
    4 {
        [ drop ]
        [ nip  ]
        [ nip  ]
        [ nip  ]
        [ nip  ]
        [ nip  ]
        [ nip  ]
        [ nip  ]
        [ nip  ]
        [ nip  ]
        [ nip  ]
        [ nip  ]
        [ nip  ]
        [ nip  ]
        [ nip  ]
        [ nip  ]
        [ nip  ]
    } single-combination ; compiled

[ ] [ single-combination-literal-test ] unit-test

: single-combination-test-alt
    {
        [ drop ]
        [ drop ]
        [ drop ]
        [ drop ]
        [ nip  ]
        [ drop ]
        [ drop ]
        [ drop ]
        [ drop ]
        [ drop ]
        [ drop ]
        [ drop ]
        [ drop ]
        [ drop ]
        [ drop ]
        [ drop ]
        [ drop ]
    } single-combination + ; compiled

[ 5 ] [ 2 3 4 single-combination-test-alt ] unit-test
[ 7/2 ] [ 2 3 3/2 single-combination-test-alt ] unit-test

DEFER: single-combination-test-2

: single-combination-test-4
    not single-combination-test-2 ;

: single-combination-test-3
    drop 3 ;

: single-combination-test-2
    {
        [ single-combination-test-3 ]
        [ single-combination-test-3 ]
        [ single-combination-test-3 ]
        [ single-combination-test-3 ]
        [ single-combination-test-3 ]
        [ single-combination-test-3 ]
        [ single-combination-test-4 ]
        [ single-combination-test-3 ]
        [ single-combination-test-3 ]
        [ single-combination-test-3 ]
        [ single-combination-test-3 ]
        [ single-combination-test-3 ]
        [ single-combination-test-3 ]
        [ single-combination-test-3 ]
        [ single-combination-test-3 ]
        [ single-combination-test-3 ]
        [ single-combination-test-3 ]
    } single-combination ;

[ 3 ] [ t single-combination-test-2 ] unit-test
[ 3 ] [ 3 single-combination-test-2 ] unit-test
[ 3 ] [ f single-combination-test-2 ] unit-test
