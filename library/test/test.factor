! Factor test suite.

IN: test
USING: errors kernel lists math memory namespaces parser
prettyprint sequences stdio strings unparser vectors words ;

: assert ( t -- )
    [ "Assertion failed!" throw ] unless ;

: print-test ( input output -- )
    "--> " write 2list . flush ;

: keep-datastack ( quot -- ) datastack slip set-datastack drop ;

: time ( code -- )
    #! Evaluates the given code and prints the time taken to
    #! execute it.
    millis >r gc-time >r call gc-time r> - millis r> -
    [
        unparse , " ms run / " , unparse , " ms GC time" ,
    ] make-string print ;

: unit-test ( output input -- )
    [
        [
            2dup print-test
            swap >r >r clear r> call
            datastack >list r> = assert
        ] keep-datastack 2drop
    ] time ;

: unit-test-fails ( quot -- )
    #! Assert that the quotation throws an error.
    [ [ not ] catch ] cons [ f ] swap unit-test ;

: assert-depth ( quot -- )
    depth slip depth = [
        "Unequal before/after depth" throw
    ] unless ;

SYMBOL: failures

: failure failures [ cons ] change ;

: test-handler ( name quot -- ? )
    [ [ dup error. cons failure f ] [ t ] ifte* ] catch ;

: test-path ( name -- path )
    "/library/test/" swap ".factor" cat3 ;

: test ( name -- ? )
    [
        "=====> " write dup write "..." print
        test-path [ [ run-resource ] keep ] assert-depth drop
    ] test-handler ;

: prepare-tests ( -- )
    failures off
    vocabularies get [ "temporary" off ] bind ;

: eligible-tests ( -- list )
    [
        [
            "lists/cons" "lists/lists" "lists/assoc"
            "lists/namespaces" "lists/combinators" "combinators"
            "continuations" "errors" "hashtables" "strings"
            "namespaces" "generic" "tuple" "files" "parser"
            "parse-number" "prettyprint" "image" "init" "io/io"
            "listener" "vectors" "words" "unparser" "random"
            "stream" "math/bitops"
            "math/math-combinators" "math/rational" "math/float"
            "math/complex" "math/irrational" "math/integer"
            "math/matrices"
            "httpd/url-encoding" "httpd/html" "httpd/httpd"
            "httpd/http-client"
            "crashes" "sbuf" "threads" "parsing-word"
            "inference" "dataflow" "interpreter" "alien"
            "line-editor" "gadgets" "memory" "redefine"
            "annotate"
        ] %
        
        os "win32" = [
            "buffer" ,
        ] when
        
        cpu "unknown" = [
            [
                "io/buffer" "compiler/optimizer"
                "compiler/simplifier" "compiler/simple"
                "compiler/stack" "compiler/ifte"
                "compiler/generic" "compiler/bail-out"
                "compiler/linearizer" "compiler/intrinsics"
            ] %
        ] unless
        
        [
            "benchmark/empty-loop" "benchmark/fac"
            "benchmark/fib" "benchmark/sort"
            "benchmark/continuations" "benchmark/ack"
            "benchmark/hashtables" "benchmark/strings"
            "benchmark/vectors"
        ] %
    ] make-list ;

: passed.
    "Tests passed:" print . ;

: failed.
    "Tests failed:" print
    failures get [ unswons write ": " write error. ] each ;

: all-tests ( -- )
    prepare-tests eligible-tests [ test ] subset
    terpri passed. failed. ;
