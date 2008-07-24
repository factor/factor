IN: compiler.tree.combinators.tests
USING: compiler.tree.combinators compiler.tree.builder tools.test
kernel ;

[ ] [ [ 1 ] build-tree [ ] transform-nodes drop ] unit-test
[ ] [ [ 1 2 3 ] build-tree [ ] transform-nodes drop ] unit-test

{ 1 0 } [ [ iterate-next ] iterate-nodes ] must-infer-as

{ 1 0 }
[
    [ [ iterate-next ] iterate-nodes ] with-node-iterator
] must-infer-as

{ 1 0 } [ [ drop ] each-node ] must-infer-as

{ 1 0 } [ [ ] map-children ] must-infer-as
