IN: stack-checker.dependencies.tests
USING: tools.test stack-checker.dependencies words kernel namespaces
definitions ;

: computing-dependencies ( quot -- dependencies )
    H{ } clone [ dependencies rot with-variable ] keep ;
    inline

SYMBOL: a
SYMBOL: b

[ ] [ a called-dependency depends-on ] unit-test

[ H{ { a called-dependency } } ] [
    [ a called-dependency depends-on ] computing-dependencies
] unit-test

[ H{ { a called-dependency } { b inlined-dependency } } ] [
    [
        a called-dependency depends-on b inlined-dependency depends-on
    ] computing-dependencies
] unit-test

[ H{ { a inlined-dependency } { b inlined-dependency } } ] [
    [
        a inlined-dependency depends-on
        a called-dependency depends-on
        b inlined-dependency depends-on
    ] computing-dependencies
] unit-test

[ flushed-dependency ] [ f flushed-dependency strongest-dependency ] unit-test
[ flushed-dependency ] [ flushed-dependency f strongest-dependency ] unit-test
[ inlined-dependency ] [ flushed-dependency inlined-dependency strongest-dependency ] unit-test
[ inlined-dependency ] [ called-dependency inlined-dependency strongest-dependency ] unit-test
[ flushed-dependency ] [ called-dependency flushed-dependency strongest-dependency ] unit-test
[ called-dependency ] [ called-dependency f strongest-dependency ] unit-test
