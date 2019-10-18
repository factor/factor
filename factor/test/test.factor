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

~<< 3dup A B C -- A B C A B C >>~

: test-word ( output word input )
    3dup 3list .
    append compile-no-name unit expand assert= ;

: test ( name -- )
    ! Run the given test.
    "/factor/test/" swap ".factor" cat3 runResource ;

: all-tests ( -- )
    "Running Factor test suite..." print
    [
        "combinators"
        "compiler"
        "dictionary"
        "list"
        "miscellaneous"
        "random"
        "stack"
    ] [
        test
    ] each
    "All tests passed." print ;
