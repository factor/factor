IN: scratchpad
USE: arithmetic
USE: combinators
USE: continuations
USE: kernel
USE: lists
USE: namespaces
USE: stack
USE: stdio
USE: test

: callcc1-test ( x -- list )
    [
        "test-cc" set [ ] [
            swap pred tuck swons
            over 0 = [ "test-cc" get call ] when
        ] forever
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
