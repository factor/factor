! Factor test suite.

! Some of these words should be moved to the standard library.

IN: test
USE: errors
USE: kernel
USE: lists
USE: math
USE: namespaces
USE: parser
USE: prettyprint
USE: stdio
USE: strings
USE: words
USE: vectors
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
    millis >r gc-time >r call gc-time r> - millis r> -
    unparse write " milliseconds run time" print
    unparse write " milliseconds GC time" print ;

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
    depth 1 - >r
    "Testing " write dup write "..." print
    "/library/test/" swap ".factor" cat3 run-resource
    "Checking before/after depth..." print
    depth r> = assert ;

: all-tests ( -- )
    "Running Factor test suite..." print
    vocabularies get [ "scratchpad" off ] bind
    [
        "lists/cons"
        "lists/lists"
        "lists/assoc"
        "lists/namespaces"
        "lists/combinators"
        "combinators"
        "continuations"
        "errors"
        "hashtables"
        "strings"
        "namespaces"
        "generic"
        "files"
        "parser"
        "parse-number"
        "prettyprint"
        "image"
        "init"
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
        "httpd/url-encoding"
        "httpd/html"
        "httpd/httpd"
        "crashes"
        "sbuf"
        "threads"
        "parsing-word"
        "inference"
        "dataflow"
        "interpreter"
        "hsv"
        "alien"
        "line-editor"
    ] [
        test
    ] each
    
    cpu "x86" = [
        [
            "compiler/optimizer"
            "compiler/simplifier"
            "compiler/simple"
            "compiler/stack"
            "compiler/ifte"
            "compiler/generic"
            "compiler/bail-out"
        ] [
            test
        ] each
    ] when

    [
        "benchmark/empty-loop"
        "benchmark/fac"
        "benchmark/fib"
        "benchmark/sort" 
        "benchmark/continuations"
        "benchmark/ack" 
        "benchmark/hashtables"
        "benchmark/strings"
        "benchmark/vectors"
    ] [
        test
    ] each ;
