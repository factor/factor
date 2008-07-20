

[ ] [ [ 1 ] dataflow [ ] transform-nodes drop ] unit-test
[ ] [ [ 1 2 3 ] dataflow [ ] transform-nodes drop ] unit-test

USE: inference.dataflow

{ 1 0 } [ [ iterate-next ] iterate-nodes ] must-infer-as

{ 1 0 }
[
    [ [ iterate-next ] iterate-nodes ] with-node-iterator
] must-infer-as

{ 1 0 } [ [ drop ] each-node ] must-infer-as

{ 1 0 } [ [ ] map-children ] must-infer-as
