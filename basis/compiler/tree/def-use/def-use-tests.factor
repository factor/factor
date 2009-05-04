USING: accessors namespaces assocs kernel sequences math
tools.test words sets combinators.short-circuit
stack-checker.state compiler.tree compiler.tree.builder
compiler.tree.recursive compiler.tree.normalization
compiler.tree.propagation compiler.tree.cleanup
compiler.tree.def-use arrays kernel.private sorting math.order
binary-search compiler.tree.checker ;
IN: compiler.tree.def-use.tests

[ t ] [
    [ 1 2 3 ] build-tree compute-def-use drop
    def-use get {
        [ assoc-size 3 = ]
        [ values [ uses>> [ #return? ] all? ] all? ]
    } 1&&
] unit-test

: test-def-use ( quot -- )
    build-tree
    analyze-recursive
    normalize
    propagate
    cleanup
    compute-def-use
    check-nodes ;

: too-deep ( a b -- c )
    dup [ drop ] [ 2dup too-deep too-deep drop ] if ; inline recursive

[ ] [
    [ too-deep ]
    build-tree
    analyze-recursive
    normalize
    compute-def-use
    check-nodes
] unit-test

! compute-def-use checks for SSA violations, so we use that to
! ensure we generate some common patterns correctly.
{
    [ [ drop ] each-integer ]
    [ [ 2drop ] curry each-integer ]
    [ [ 1 ] [ 2 ] if drop ]
    [ [ 1 ] [ dup ] if ]
    [ [ 1 ] [ dup ] if drop ]
    [ { array } declare swap ]
    [ [ ] curry call ]
    [ [ 1 ] [ 2 ] compose call + ]
    [ [ 1 ] 2 [ + ] curry compose call + ]
    [ [ 1 ] [ call 2 ] curry call + ]
    [ [ 1 ] [ 2 ] compose swap [ 1 ] [ 2 ] if + * ]
    [ dup slice? [ dup array? [ ] [ ] if ] [ ] if ]
    [ dup [ drop f ] [ "A" throw ] if ]
    [ [ <=> ] sort ]
    [ [ <=> ] with search ]
} [
    [ ] swap [ test-def-use ] curry unit-test
] each
