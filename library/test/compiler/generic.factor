IN: scratchpad
USE: compiler
USE: test
USE: math
USE: kernel
USE: words

: generic-test
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
    } generic ; compiled

[ 2 3 ] [ 2 3 t generic-test ] unit-test
[ 2 3 ] [ 2 3 4 generic-test ] unit-test
[ 2 f ] [ 2 3 f generic-test ] unit-test

: generic-literal-test
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
    } generic ; compiled

[ ] [ generic-literal-test ] unit-test

: generic-test-alt
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
    } generic + ; compiled

[ 5 ] [ 2 3 4 generic-test-alt ] unit-test
[ 7/2 ] [ 2 3 3/2 generic-test-alt ] unit-test

DEFER: generic-test-2

: generic-test-4
    not generic-test-2 ;

: generic-test-3
    drop 3 ;

: generic-test-2
    {
        [ generic-test-3 ]
        [ generic-test-3 ]
        [ generic-test-3 ]
        [ generic-test-3 ]
        [ generic-test-3 ]
        [ generic-test-3 ]
        [ generic-test-4 ]
        [ generic-test-3 ]
        [ generic-test-3 ]
        [ generic-test-3 ]
        [ generic-test-3 ]
        [ generic-test-3 ]
        [ generic-test-3 ]
        [ generic-test-3 ]
        [ generic-test-3 ]
        [ generic-test-3 ]
        [ generic-test-3 ]
    } generic ;

[ 3 ] [ t generic-test-2 ] unit-test
[ 3 ] [ 3 generic-test-2 ] unit-test
[ 3 ] [ f generic-test-2 ] unit-test
