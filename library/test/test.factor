! Copyright (C) 2003, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: test
USING: arrays errors hashtables inspector io kernel math
memory namespaces parser prettyprint sequences strings words
vectors ;

TUPLE: assert got expect ;

M: assert summary drop "Assertion failed" ;

: assert= ( a b -- ) 2dup = [ 2drop ] [ <assert> throw ] if ;

: print-test ( input output -- ) "--> " write 2array . flush ;

: benchmark ( quot -- gctime runtime )
    millis >r gc-time >r call gc-time r> - millis r> - ;

: time ( code -- )
    benchmark
    [ # " ms run / " % # " ms GC time" % ] "" make print flush ;

: unit-test ( output input -- )
    [
        [
            2dup print-test
            swap >r >r clear r> call
            datastack r> >vector assert=
        ] keep-datastack 2drop
    ] time ;

: unit-test-fails ( quot -- )
    [ f ] swap [ [ call t ] [ 2drop f ] recover ]
    curry unit-test ;

: assert-depth ( quot -- ) depth slip depth assert= ;

SYMBOL: failures

: failure failures [ ?push ] change ;

: test-handler ( name quot -- ? )
    catch [ dup error. 2array failure f ] [ t ] if* ;

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
    failures off "temporary" forget-vocab ;

: passed.
    "Tests passed:" print . ;

: failed.
    "Tests failed:" print
    failures get [ first2 swap write ": " write error. ] each ;

: run-tests ( list -- )
    prepare-tests [ test ] subset terpri passed. failed. ;

: tests
    {
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
        "gadgets/line-editor" "gadgets/rectangles" "memory"
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
        "compiler/simple" "compiler/templates"
        "compiler/stack" "compiler/ifte"
        "compiler/generic" "compiler/bail-out"
        "compiler/intrinsics" "compiler/float"
        "compiler/identities" "compiler/optimizer"
        "compiler/alien" "compiler/callbacks"
    } run-tests ;
