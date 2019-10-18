USING: accessors assocs compiler.tree.builder compiler.tree.propagation
compiler.tree.propagation.inlining kernel math sequences tools.test ;
IN: compiler.tree.propagation.inlining.tests

{ t } [
    [ >bignum 10 mod ] build-tree propagate
    fourth dup word>> do-inlining
] unit-test

! never-inline-word?
{ t } [
    \ + props>> "default-method" of  never-inline-word?
] unit-test
