IN: temporary
USE: kernel
USE: lists
USE: math
USE: namespaces
USE: io
USE: test

: (callcc1-test)
    swap 1 - tuck swons
    over 0 = [ "test-cc" get call ] when
    (callcc1-test) ;

: callcc1-test ( x -- list )
    [
        "test-cc" set [ ] (callcc1-test)
    ] callcc1 nip ;

: callcc-namespace-test ( -- ? )
    [
        "test-cc" set
        5 "x" set
        [
            6 "x" set "test-cc" get call
        ] with-scope
    ] callcc0 "x" get 5 = ;

[ t ] [ 10 callcc1-test 10 count = ] unit-test
[ t ] [ callcc-namespace-test ] unit-test

: multishot-test ( -- stack )
    [ dup "cc" set 5 swap call ] callcc1 "cc" get car interp-data ;

[ 5 { } ] [ multishot-test ] unit-test
