USING: kernel tools.test compiler.tree compiler.tree.builder
compiler.tree.recursive compiler.tree.def-use
compiler.tree.def-use.simplified accessors sequences sorting classes ;
IN: compiler.tree.def-use.simplified

{ { #call #return } } [
    [ 1 dup reverse ] build-tree compute-def-use
    first out-d>> first actually-used-by
    [ node>> class-of ] map sort
] unit-test

: word-1 ( a -- b ) dup [ word-1 ] when ; inline recursive

{ { #introduce } } [
    [ word-1 ] build-tree analyze-recursive compute-def-use
    last in-d>> first actually-defined-by
    [ node>> class-of ] map sort
] unit-test

{ { #if #return } } [
    [ word-1 ] build-tree analyze-recursive compute-def-use
    first out-d>> first actually-used-by
    [ node>> class-of ] map sort
] unit-test
