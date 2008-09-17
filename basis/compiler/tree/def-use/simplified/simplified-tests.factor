USING: kernel tools.test compiler.tree compiler.tree.builder
compiler.tree.def-use compiler.tree.def-use.simplified accessors
sequences sorting classes ;
IN: compiler.tree.def-use.simplified

[ { #call #return } ] [
    [ 1 dup reverse ] build-tree compute-def-use
    first out-d>> first actually-used-by
    [ node>> class ] map natural-sort
] unit-test
