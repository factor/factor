! Factor test suite.

IN: test
USING: errors kernel lists math memory namespaces parser
prettyprint sequences io strings unparser vectors words ;

TUPLE: assert got expect ;

M: assert error.
    "Assertion failed" print
    "Expected: " write dup assert-expect .
    "Got: " write assert-got . ;

: assert= ( a b -- )
    2dup = [ 2drop ] [ <assert> throw ] ifte ;

: print-test ( input output -- )
    "--> " write 2list . flush ;

: time ( code -- )
    #! Evaluates the given code and prints the time taken to
    #! execute it.
    millis >r gc-time >r call gc-time r> - millis r> -
    [
        unparse % " ms run / " % unparse % " ms GC time" %
    ] make-string print ;

: unit-test ( output input -- )
    [
        [
            2dup print-test
            swap >r >r clear r> call
            datastack >list r> assert=
        ] keep-datastack 2drop
    ] time ;

: unit-test-fails ( quot -- )
    #! Assert that the quotation throws an error.
    [ [ not ] catch ] cons [ f ] swap unit-test ;

: assert-depth ( quot -- )
    depth slip depth assert= ;

SYMBOL: failures

: failure failures [ cons ] change ;

: test-handler ( name quot -- ? )
    [ [ dup error. cons failure f ] [ t ] ifte* ] catch ;

: test-path ( name -- path )
    "/library/test/" swap ".factor" append3 ;

: test ( name -- ? )
    [
        "=====> " write dup write "..." print
        test-path [ [ run-resource ] keep ] assert-depth drop
    ] test-handler ;

: prepare-tests ( -- )
    failures off
    vocabularies get [ "temporary" off ] bind ;

: passed.
    "Tests passed:" print . ;

: failed.
    "Tests failed:" print
    failures get [ unswons write ": " write error. ] each ;

: run-tests ( list -- )
    prepare-tests [ test ] subset terpri passed. failed. ;

: tests
    [
        "lists/cons" "lists/lists" "lists/assoc"
        "lists/namespaces" "lists/queues"
        "combinators"
        "continuations" "errors" "hashtables" "strings"
        "namespaces" "generic" "tuple" "files" "parser"
        "parse-number" "init" "io/io"
        "listener" "vectors" "words" "unparser" "random"
        "stream" "math/bitops"
        "math/math-combinators" "math/rational" "math/float"
        "math/complex" "math/irrational" "math/integer"
        "math/matrices"
        "httpd/url-encoding" "httpd/html" "httpd/httpd"
        "httpd/http-client" "sbuf" "threads" "parsing-word"
        "inference" "interpreter" "alien"
        "gadgets/line-editor" "gadgets/rectangles"
        "gadgets/gradients" "memory"
        "redefine" "annotate" "sequences" "binary" "inspector"
        "kernel"
    ] run-tests ;

: benchmarks
    [
        "benchmark/empty-loop" "benchmark/fac"
        "benchmark/fib" "benchmark/sort"
        "benchmark/continuations" "benchmark/ack"
        "benchmark/hashtables" "benchmark/strings"
        "benchmark/vectors" "benchmark/prettyprint"
        "benchmark/image"
    ] run-tests ;

: compiler-tests
    [
        "io/buffer" "compiler/optimizer"
        "compiler/simple"
        "compiler/stack" "compiler/ifte"
        "compiler/generic" "compiler/bail-out"
        "compiler/linearizer" "compiler/intrinsics"
        "compiler/identities"
    ] run-tests ;

: all-tests tests compiler-tests benchmarks ;
