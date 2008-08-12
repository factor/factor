IN: compiler.tree.propagation.recursive.tests
USING: tools.test compiler.tree.propagation.recursive
math.intervals kernel ;

[ T{ interval f { 0 t } { 1/0. t } } ] [
    T{ interval f { 1 t } { 1 t } }
    T{ interval f { 0 t } { 0 t } } generalize-counter-interval
] unit-test

[ T{ interval f { -1/0. t } { 10 t } } ] [
    T{ interval f { -1 t } { -1 t } }
    T{ interval f { 10 t } { 10 t } } generalize-counter-interval
] unit-test

[ t ] [
    T{ interval f { 1 t } { 268435455 t } }
    T{ interval f { -268435456 t } { 268435455 t } } tuck
    generalize-counter-interval =
] unit-test
