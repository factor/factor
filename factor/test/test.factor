! Factor test suite.

! Some of these words should be moved to the standard library.

: assert ( t -- )
    [ "Assertion failed!" break ] unless ;

: assert= ( x y -- )
    = assert ;

: compile-maybe ( -- )
    $compile [ word compile ] when ;

: compile-no-name ( list -- )
    no-name compile-maybe ;

: must-compile ( word -- )
    $compile [
        "Checking if " write dup " was compiled" print
        dup compile
        worddef compiled? assert
    ] [
        drop
    ] ifte ;

: test-word ( output input word -- )
    3dup 3list .
    append compile-no-name unit expand assert= ;

: do-not-test-word ( output input word -- )
    #! Flag for tests that are known not to work.
    drop drop drop ;

: test ( name -- )
    ! Run the given test.
    "/factor/test/" swap ".factor" cat3 run-resource ;

: all-tests ( -- )
    "Running Factor test suite..." print
    [
        "auxiliary"
        "combinators"
        "compiler"
        "dictionary"
        "list"
        "math"
        "miscellaneous"
        "namespaces"
        "random"
        "reader"
        "stack"
        "string"
        "tail"
        "reboot"
    ] [
        test
    ] each
    "All tests passed." print ;
