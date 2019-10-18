IN: temporary
USE: kernel
USE: math
USE: namespaces
USE: io
USE: test
USE: sequences
USE: vectors

: (callcc1-test)
    swap 1- tuck swap ?push
    over 0 = [ "test-cc" get continue-with ] when
    (callcc1-test) ;

: callcc1-test ( x -- list )
    [
        "test-cc" set V{ } clone (callcc1-test)
    ] callcc1 nip ;

: callcc-namespace-test ( -- ? )
    [
        "test-cc" set
        5 "x" set
        [
            6 "x" set "test-cc" get continue
        ] with-scope
    ] callcc0 "x" get 5 = ;

[ t ] [ 10 callcc1-test 10 reverse >vector = ] unit-test
[ t ] [ callcc-namespace-test ] unit-test
