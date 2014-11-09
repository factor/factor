USING: accessors arrays combinators.short-circuit compiler.cfg.dependence
compiler.cfg.instructions fry kernel namespaces sequences tools.test ;
IN: compiler.cfg.dependence.tests
FROM: sets => set= ;

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


! Verification tests
ERROR: node-missing-parent trees nodes ;
ERROR: node-missing-children trees nodes ;

: flatten-tree ( node -- nodes )
    [ children>> [ flatten-tree ] map concat ] keep suffix ;

: verify-parents ( nodes trees -- )
    2dup '[ [ parent>> ] [ _ member? ] bi or ] all?
    [ 2drop ] [ node-missing-parent ] if ;

: verify-children ( nodes trees -- )
    2dup [ flatten-tree ] map concat
    { [ [ length ] same? ] [ set= ] } 2&&
    [ 2drop ] [ node-missing-children ] if ;

: verify-trees ( nodes trees -- )
    [ verify-parents ] [ verify-children ] 2bi ;

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
