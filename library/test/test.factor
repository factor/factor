! Factor test suite.

! Some of these words should be moved to the standard library.

IN: test
USE: arithmetic
USE: combinators
USE: compiler
USE: errors
USE: kernel
USE: lists
USE: namespaces
USE: parser
USE: prettyprint
USE: stack
USE: stdio
USE: strings
USE: words
USE: unparser
USE: vocabularies

: assert ( t -- )
    [ "Assertion failed!" throw ] unless ;

: assert= ( x y -- )
    = assert ;

: must-compile ( word -- )
    "compile" get [
        "Checking if " write dup write " was compiled" print
        dup compile
        worddef compiled? assert
    ] [
        drop
    ] ifte ;

: test-word ( output input word -- )
    3dup 3list .
    append expand assert= ;

: do-not-test-word ( output input word -- )
    #! Flag for tests that are known not to work.
    3drop ;

: time ( code -- )
    #! Evaluates the given code and prints the time taken to
    #! execute it.
    millis >r call millis r> - . ;

: test ( name -- )
    ! Run the given test.
    "/library/test/" swap ".factor" cat3 run-resource ;

: all-tests ( -- )
    "Running Factor test suite..." print
    "vocabularies" get [ f "scratchpad" set ] bind
    [
        "assoc"
        "auxiliary"
        "combinators"
        "compiler"
        "compiler-types"
        "continuations"
        "dictionary"
        "format"
        "hashtables"
        "html"
        "httpd"
        "inference"
        "list"
        "math"
        "miscellaneous"
        "namespaces"
        "parse-number"
        "prettyprint"
        "primitives"
        "random"
        "reader"
        "recompile"
        "stack"
        "string"
        "tail"
        "types"
        "vectors"
    ] [
        test
    ] each
    "All tests passed." print ;
