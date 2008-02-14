IN: temporary
USING: tools.test optimizer.control combinators kernel
sequences inference.dataflow math inference ;

: label-is-loop? ( node word -- ? )
    [
        {
            { [ over #label? not ] [ 2drop f ] }
            { [ over #label-word over eq? not ] [ 2drop f ] }
            { [ over #label-loop? not ] [ 2drop f ] }
            { [ t ] [ 2drop t ] }
        } cond
    ] curry node-exists? ;

: label-is-not-loop? ( node word -- ? )
    [
        {
            { [ over #label? not ] [ 2drop f ] }
            { [ over #label-word over eq? not ] [ 2drop f ] }
            { [ over #label-loop? ] [ 2drop f ] }
            { [ t ] [ 2drop t ] }
        } cond
    ] curry node-exists? ;

: loop-test-1 ( a -- )
    dup [ 1+ loop-test-1 ] [ drop ] if ; inline

[ t ] [
    [ loop-test-1 ] dataflow dup detect-loops
    \ loop-test-1 label-is-loop?
] unit-test

[ t ] [
    [ loop-test-1 1 2 3 ] dataflow dup detect-loops
    \ loop-test-1 label-is-loop?
] unit-test

[ t ] [
    [ [ loop-test-1 ] each ] dataflow dup detect-loops
    \ loop-test-1 label-is-loop?
] unit-test

[ t ] [
    [ [ loop-test-1 ] each ] dataflow dup detect-loops
    \ (each-integer) label-is-loop?
] unit-test

: loop-test-2 ( a -- )
    dup [ 1+ loop-test-2 1- ] [ drop ] if ; inline

[ t ] [
    [ loop-test-2 ] dataflow dup detect-loops
    \ loop-test-2 label-is-not-loop?
] unit-test

: loop-test-3 ( a -- )
    dup [ [ loop-test-3 ] each ] [ drop ] if ; inline

[ t ] [
    [ loop-test-3 ] dataflow dup detect-loops
    \ loop-test-3 label-is-not-loop?
] unit-test
