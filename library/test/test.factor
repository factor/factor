! Factor test suite.

! Some of these words should be moved to the standard library.

IN: test
USE: combinators
USE: compiler
USE: errors
USE: kernel
USE: lists
USE: math
USE: namespaces
USE: parser
USE: prettyprint
USE: stack
USE: stdio
USE: strings
USE: words
USE: unparser

: assert ( t -- )
    [ "Assertion failed!" throw ] unless ;

: print-test ( input output -- )
    "TESTING: " write 2list . flush ;

: keep-datastack ( quot -- )
    datastack >r call r> set-datastack drop ;

: unit-test ( output input -- )
    [
        2dup print-test
        swap >r >r clear r> call datastack vector>list r>
        = assert
    ] keep-datastack 2drop ;

: test-word ( output input word -- )
    #! Old-style test.
    append unit-test ;

: do-not-test-word ( output input word -- )
    #! Flag for tests that are known not to work.
    3drop ;

: time ( code -- )
    #! Evaluates the given code and prints the time taken to
    #! execute it.
    "Timing " write dup .
    millis >r call millis r> - . ;

: test ( name -- )
    ! Run the given test.
    depth pred >r
    "Testing " write dup write "..." print
    "/library/test/" swap ".factor" cat3 run-resource
    "Checking before/after depth..." print
    depth r> = assert
    ;

: all-tests ( -- )
    "Running Factor test suite..." print
    "vocabularies" get [ f "scratchpad" set ] bind
    [
        "crashes"
        "lists/cons"
        "lists/lists"
        "lists/assoc"
        "lists/destructive"
        "lists/namespaces"
        "combinators"
        "continuations"
        "errors"
        "hashtables"
        "strings"
        "namespaces/namespaces"
        "files"
        "format"
        "parser"
        "parse-number"
        "prettyprint"
        "image"
        "inspector"
        "io/io"
        "vectors"
        "words"
        "unparser"
        "random"
        "math/bignum"
        "math/bitops"
        "math/gcd"
        "math/rational"
        "math/float"
        "math/complex"
        "math/irrational"
        "math/simpson"
        "httpd/url-encoding"
        "httpd/html"
        "httpd/httpd"
    ] [
        test
    ] each
    
    native? [
        [
            "threads"
        ] [
            test
        ] each
    ] when

    java? [
        [
            "lists/java"
            "namespaces/java"
            "jvm-compiler/auxiliary"
            "jvm-compiler/compiler"
            "jvm-compiler/compiler-types"
            "jvm-compiler/inference"
            "jvm-compiler/primitives"
            "jvm-compiler/tail"
            "jvm-compiler/types"
            "jvm-compiler/miscellaneous"
        ] [
            test
        ] each
    ] when ;
