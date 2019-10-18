USING: compiler.tree.combinators tools.test kernel ;
IN: compiler.tree.combinators.tests

{ 1 0 } [ [ drop ] each-node ] must-infer-as
{ 1 1 } [ [ ] map-nodes ] must-infer-as
{ 1 1 } [ [ ] contains-node? ] must-infer-as
