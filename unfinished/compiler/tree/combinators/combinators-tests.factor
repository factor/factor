IN: compiler.tree.combinators.tests
USING: compiler.tree.combinators tools.test kernel ;

{ 1 0 } [ [ drop ] each-node ] must-infer-as
