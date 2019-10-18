USING: tools.test compiler.tree.propagation.recursive
math.intervals kernel math literals layouts ;
IN: compiler.tree.propagation.recursive.tests

[ T{ interval f { 0 t } { 1/0. t } } ] [
    T{ interval f { 1 t } { 1 t } }
    T{ interval f { 0 t } { 0 t } }
    integer generalize-counter-interval
] unit-test

[ T{ interval f { 0 t } { $[ max-array-capacity ] t } } ] [
    T{ interval f { 1 t } { 1 t } }
    T{ interval f { 0 t } { 0 t } }
    fixnum generalize-counter-interval
] unit-test

[ T{ interval f { -1/0. t } { 10 t } } ] [
    T{ interval f { -1 t } { -1 t } }
    T{ interval f { 10 t } { 10 t } }
    integer generalize-counter-interval
] unit-test

[ T{ interval f { $[ most-negative-fixnum ] t } { 10 t } } ] [
    T{ interval f { -1 t } { -1 t } }
    T{ interval f { 10 t } { 10 t } }
    fixnum generalize-counter-interval
] unit-test

[ t ] [
    T{ interval f { -268435456 t } { 268435455 t } }
    T{ interval f { 1 t } { 268435455 t } }
    over
    integer generalize-counter-interval =
] unit-test

[ t ] [
    T{ interval f { -268435456 t } { 268435455 t } }
    T{ interval f { 1 t } { 268435455 t } }
    over
    fixnum generalize-counter-interval =
] unit-test

[ full-interval ] [
    T{ interval f { -5 t } { 3 t } }
    T{ interval f { 2 t } { 11 t } }
    integer generalize-counter-interval
] unit-test

[ $[ fixnum-interval ] ] [
    T{ interval f { -5 t } { 3 t } }
    T{ interval f { 2 t } { 11 t } }
    fixnum generalize-counter-interval
] unit-test
