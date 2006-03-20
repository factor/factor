! Factor test suite.

IN: test
USING: arrays errors inspector io kernel lists math memory
namespaces parser prettyprint sequences strings words ;

TUPLE: assert got expect ;

M: assert summary drop "Assertion failed" ;

: assert= ( a b -- )
    2dup = [ 2drop ] [ <assert> throw ] if ;

: print-test ( input output -- )
    "--> " write 2array . flush ;

: time ( code -- )
    #! Evaluates the given code and prints the time taken to
    #! execute it.
    millis >r gc-time >r call gc-time r> - millis r> -
    [ # " ms run / " % # " ms GC time" % ] "" make print flush ;

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
    [ f ] swap [ [ call t ] [ 2drop f ] recover ]
    curry unit-test ;

: assert-depth ( quot -- )
    depth slip depth assert= ;

SYMBOL: failures

: failure failures [ cons ] change ;

: test-handler ( name quot -- ? )
    catch [ dup error. cons failure f ] [ t ] if* ;

: test-path ( name -- path )
    "/library/test/" swap ".factor" append3 ;

: test ( name -- ? )
    [
        "=====> " write dup write "..." print flush
        test-path [
            [ [ run-resource ] with-scope ] keep
        ] assert-depth drop
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
    {
        "lists/cons" "lists/lists"
        "lists/namespaces"
        "combinators"
        "continuations" "errors"
        "collections/hashtables" "collections/sbuf"
        "collections/strings" "collections/namespaces"
        "collections/vectors" "collections/sequences"
        "collections/queues" "generic" "tuple" "parser"
        "parse-number" "init" "io/io"
        "words" "prettyprint" "random" "stream" "math/bitops"
        "math/math-combinators" "math/rational" "math/float"
        "math/complex" "math/irrational"
        "math/integer" "math/random" "threads" "parsing-word"
        "inference" "interpreter" "alien"
        "gadgets/line-editor" "gadgets/rectangles"
        "gadgets/frames" "memory"
        "redefine" "annotate" "binary" "inspector"
        "kernel"
    } run-tests ;

: benchmarks
    {
        "benchmark/empty-loop" "benchmark/fac"
        "benchmark/fib" "benchmark/sort"
        "benchmark/continuations" "benchmark/ack"
        "benchmark/hashtables" "benchmark/strings"
        "benchmark/vectors" "benchmark/prettyprint"
        "benchmark/iteration"
    } run-tests ;

: compiler-tests
    {
        "io/buffer"
        "compiler/simple"
        "compiler/stack" "compiler/ifte"
        "compiler/generic" "compiler/bail-out"
        "compiler/linearizer" "compiler/intrinsics"
        "compiler/identities" "compiler/optimizer"
        "compiler/alien" "compiler/callbacks"
    } run-tests ;
