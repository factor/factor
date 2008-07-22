USING: kernel compiler.frontend compiler.tree
compiler.tree.propagation tools.test math accessors
sequences arrays kernel.private ;
IN: compiler.tree.propagation.tests

: final-info ( quot -- seq )
    dataflow propagate last-node node-input-infos ;

: final-classes ( quot -- seq )
    final-info [ class>> ] map ;

: final-literals ( quot -- seq )
    final-info [ literal>> ] map ;

[ V{ } ] [ [ ] final-classes ] unit-test

[ V{ fixnum } ] [ [ 1 ] final-classes ] unit-test

[ V{ fixnum } ] [ [ 1 >r r> ] final-classes ] unit-test

[ V{ fixnum object } ] [ [ 1 swap ] final-classes ] unit-test

[ V{ array } ] [ [ 10 f <array> ] final-classes ] unit-test

[ V{ array } ] [ [ { array } declare ] final-classes ] unit-test

[ V{ array } ] [ [ 10 f <array> swap [ ] [ ] if ] final-classes ] unit-test

[ V{ fixnum } ] [ [ dup fixnum? [ ] [ drop 3 ] if ] final-classes ] unit-test

[ V{ 69 } ] [ [ [ 69 ] [ 69 ] if ] final-literals ] unit-test

[ V{ fixnum } ] [ [ { fixnum } declare bitnot ] final-classes ] unit-test

[ V{ number } ] [ [ + ] final-classes ] unit-test

[ V{ float } ] [ [ { float integer } declare + ] final-classes ] unit-test

[ V{ float } ] [ [ /f ] final-classes ] unit-test

[ V{ integer } ] [ [ /i ] final-classes ] unit-test

[ V{ integer } ] [ [ 255 bitand ] final-classes ] unit-test

[ V{ integer } ] [
    [ [ 255 bitand ] [ 65535 bitand ] bi + ] final-classes
] unit-test

[ V{ fixnum } ] [
    [
        { fixnum } declare [ 255 bitand ] [ 65535 bitand ] bi +
    ] final-classes
] unit-test

[ V{ integer } ] [
    [ { fixnum } declare [ 255 bitand ] keep + ] final-classes
] unit-test

[ V{ integer } ] [
    [ { fixnum } declare 615949 * ] final-classes
] unit-test

[ V{ null } ] [
    [ { null null } declare + ] final-classes
] unit-test

[ V{ fixnum } ] [
    [ { null fixnum } declare + ] final-classes
] unit-test

[ V{ float } ] [
    [ { float fixnum } declare + ] final-classes
] unit-test

[ V{ fixnum } ] [
    [ 255 bitand >fixnum 3 bitor ] final-classes
] unit-test

[ V{ 0 } ] [
    [ >fixnum 1 mod ] final-literals
] unit-test

[ V{ 69 } ] [
    [ >fixnum swap [ 1 mod 69 + ] [ drop 69 ] if ] final-literals
] unit-test

[ V{ fixnum } ] [
    [ >fixnum dup 10 > [ 1 - ] when ] final-classes
] unit-test
