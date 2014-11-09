USING: accessors arrays compiler.cfg.dependence compiler.cfg.instructions
kernel namespaces sequences tools.test ;
IN: compiler.cfg.dependence.tests

{
    V{
        T{ node
           { number 1 }
           { insn T{ ##inc-r } }
           { precedes H{ } }
           { follows V{ } }
        }
        T{ node
           { number 2 }
           { insn T{ ##inc-d } }
           { precedes H{ } }
           { follows V{ } }
        }
    }
} [
    0 node-number set-global
    V{ T{ ##inc-r } T{ ##inc-d } } [ <node> ] map dup
    build-dependence-graph
] unit-test

{ 0 } [
    T{ ##load-tagged } <node> calculate-registers
] unit-test

: 2node-tree ( -- tree )
    2 iota [ node new swap >>number ] map first2 over attach-parent ;

! 0 -> 1 -> 2
: 3node-tree ( -- tree )
    3 iota [ node new swap >>number ] map first3
    over attach-parent over attach-parent ;

{ } [ 2node-tree 1array dup verify-parents ] unit-test

[
    2node-tree 1array { } verify-parents
] [ node-missing-parent? ] must-fail-with


{ 1 } [ 3node-tree children>> length ] unit-test

{ 3 } [ 3node-tree flatten-tree length ] unit-test

[
    { } 3node-tree 1array verify-children
] [ node-missing-children? ] must-fail-with

[
    { } 3node-tree 1array verify-trees
] [ node-missing-children? ] must-fail-with
