USING: accessors namespaces assocs kernel sequences math
tools.test words sets combinators.short-circuit
stack-checker.state compiler.tree compiler.tree.builder
compiler.tree.def-use arrays kernel.private ;
IN: compiler.tree.def-use.tests

\ compute-def-use must-infer

[ t ] [
    [ 1 2 3 ] build-tree compute-def-use drop
    def-use get {
        [ assoc-size 3 = ]
        [ values [ uses>> [ #return? ] all? ] all? ]
    } 1&&
] unit-test

! compute-def-use checks for SSA violations, so we make sure
! some common patterns are generated correctly.
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
} [
    [ ] swap [ build-tree compute-def-use drop ] curry unit-test
] each
