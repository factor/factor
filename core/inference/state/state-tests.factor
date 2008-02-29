IN: temporary
USING: tools.test inference.state words ;

SYMBOL: a
SYMBOL: b

[ ] [ a +called+ depends-on ] unit-test

[ H{ { a +called+ } } ] [
    [ a +called+ depends-on ] computing-dependencies
] unit-test

[ H{ { a +called+ } { b +inlined+ } } ] [
    [
        a +called+ depends-on b +inlined+ depends-on
    ] computing-dependencies
] unit-test

[ H{ { a +inlined+ } { b +inlined+ } } ] [
    [
        a +inlined+ depends-on
        a +called+ depends-on
        b +inlined+ depends-on
    ] computing-dependencies
] unit-test
