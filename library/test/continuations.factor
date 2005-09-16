IN: temporary
USE: kernel
USE: lists
USE: math
USE: namespaces
USE: io
USE: test

: (callcc1-test)
    swap 1 - tuck swons
    over 0 = [ "test-cc" get continue-with ] when
    (callcc1-test) ;

: callcc1-test ( x -- list )
    [
        "test-cc" set [ ] (callcc1-test)
    ] with-continuation nip ;

: callcc-namespace-test ( -- ? )
    [
        "test-cc" set
        5 "x" set
        [
            6 "x" set "test-cc" get continue
        ] with-scope
    ] with-continuation "x" get 5 = ;

[ t ] [ 10 callcc1-test 10 >list = ] unit-test
[ t ] [ callcc-namespace-test ] unit-test

: multishot-test ( -- stack )
    [
        dup "cc" set 5 swap continue-with
    ] with-continuation "cc" get interp-data ;

[ 5 { } ] [ multishot-test ] unit-test

[ ] [
    [
        global [ "x" set ] bind
        [ global [ "x" get ] bind continue ] quot>interp
        continue
    ] with-continuation global [ "x" off ] bind
] unit-test
