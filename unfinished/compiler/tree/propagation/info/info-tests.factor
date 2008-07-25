USING: accessors math math.intervals sequences classes.algebra
math kernel tools.test compiler.tree.propagation.info ;
IN: compiler.tree.propagation.info.tests

[ f ] [ 0.0 -0.0 eql? ] unit-test

[ t ] [
    number <class-info>
    sequence <class-info>
    value-info-intersect
    class>> integer class=
] unit-test

[ t t ] [
    0 10 [a,b] <interval-info>
    5 20 [a,b] <interval-info>
    value-info-intersect
    [ class>> real class= ]
    [ interval>> 5 10 [a,b] = ]
    bi
] unit-test

[ float 10.0 t ] [
    10.0 <literal-info>
    10.0 <literal-info>
    value-info-intersect
    [ class>> ] [ >literal< ] bi
] unit-test

[ null ] [
    10 <literal-info>
    10.0 <literal-info>
    value-info-intersect
    class>>
] unit-test

[ fixnum 10 t ] [
    10 <literal-info>
    10 <literal-info>
    value-info-union
    [ class>> ] [ >literal< ] bi
] unit-test

[ 3.0 t ] [
    3 3 [a,b] <interval-info> float <class-info>
    value-info-intersect >literal<
] unit-test

[ 3 t ] [
    2 3 (a,b] <interval-info> fixnum <class-info>
    value-info-intersect >literal<
] unit-test

[ T{ value-info f null empty-interval f f } ] [
    fixnum -10 0 [a,b] <class/interval-info>
    fixnum 19 29 [a,b] <class/interval-info>
    value-info-intersect
] unit-test

[ 3 t ] [
    3 <literal-info>
    null <class-info> value-info-union >literal<
] unit-test
