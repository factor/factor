! Factor test suite.

! Some of these words should be moved to the standard library.

IN: test
USE: combinators
USE: errors
USE: kernel
USE: lists
USE: logic
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

: time ( code -- )
    #! Evaluates the given code and prints the time taken to
    #! execute it.
    millis >r call millis r> -
    unparse write " milliseconds" print ;

: unit-test ( output input -- )
    [
        [
            2dup print-test
            swap >r >r clear r> call datastack vector>list r>
            = assert
        ] keep-datastack 2drop
    ] time ;

: unit-test-fails ( quot -- )
    #! Assert that the quotation throws an error.
    [ [ not ] catch ] cons [ f ] swap unit-test ;

: test-word ( output input word -- )
    #! Old-style test.
    append unit-test ;

: do-not-test-word ( output input word -- )
    #! Flag for tests that are known not to work.
    3drop ;

: test ( name -- )
    ! Run the given test.
    depth pred >r
    "Testing " write dup write "..." print
    "/library/test/" swap ".factor" cat3 run-resource
    "Checking before/after depth..." print
    depth r> = assert ;

: all-tests ( -- )
    "Running Factor test suite..." print
    "vocabularies" get [ f "scratchpad" set ] bind
    [
        "lists/cons"
        "lists/lists"
        "lists/assoc"
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
        "init"
        "inspector"
        "io/io"
        "listener"
        "vectors"
        "words"
        "unparser"
        "random"
        "stream"
        "styles"
        "math/bignum"
        "math/bitops"
        "math/gcd"
        "math/math-combinators"
        "math/rational"
        "math/float"
        "math/complex"
        "math/irrational"
        "math/namespaces"
        "httpd/url-encoding"
        "httpd/html"
        "httpd/httpd"
    ] [
        test
    ] each
    
    native? [
        "crashes" test
        "sbuf" test
        "threads" test
        "parsing-word" test
        "inference" test
        "interpreter" test

        cpu "x86" = [
            [
                "hsv"
                "x86-compiler/simple"
                "x86-compiler/stack"
                "x86-compiler/ifte"
                "x86-compiler/generic"
                "x86-compiler/bail-out"
            ] [
                test
            ] each
        ] when
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
    ] when

    "benchmark/empty-loop" test
    "benchmark/fac" test
    "benchmark/fib" test
    "benchmark/sort" test 
    "benchmark/continuations" test
    "benchmark/ack" test 
    "benchmark/hashtables" test
    "benchmark/strings" test
    "benchmark/vectors" test ;
