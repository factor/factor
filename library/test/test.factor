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

: print-test ( input output -- )
    "TESTING: " write 2list . ;

: unit-test ( output input -- )
    2dup print-test
    swap >r >r clear r> call datastack vector>list r> = assert ;

: test-word ( output input word -- )
    #! Old-style test.
    append unit-test ;

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
        "lists/all"
        "combinators"
        "continuations"
        "hashtables"
        "strings"
        "namespaces/all"
        "format"
        "parser"
        "prettyprint"
        "inspector"
        "vectors"
        "unparser"
        "random"
        !
        "html"
        "httpd"
        "math"
        "parse-number"
        "jvm-compiler/all"
    ] [
        test
    ] each ;
