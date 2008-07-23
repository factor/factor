USING: kernel compiler.frontend compiler.tree
compiler.tree.propagation tools.test math math.order
accessors sequences arrays kernel.private vectors
alien.accessors alien.c-types ;
IN: compiler.tree.propagation.tests

\ propagate must-infer
\ propagate/node must-infer

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

[ V{ null } ] [
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

[ V{ integer } ] [ [ >fixnum 2 * ] final-classes ] unit-test

[ V{ integer } ] [
    [ >fixnum dup 10 < drop 2 * ] final-classes
] unit-test

[ V{ integer } ] [
    [ >fixnum dup 10 < [ 2 * ] when ] final-classes
] unit-test

[ V{ integer } ] [
    [ >fixnum dup 10 < [ 2 * ] [ 2 * ] if ] final-classes
] unit-test

[ V{ fixnum } ] [
    [ >fixnum dup 10 < [ dup -10 > [ 2 * ] when ] when ] final-classes
] unit-test

[ V{ f } ] [
    [ dup 10 < [ dup 8 > [ drop 9 ] unless ] [ drop 9 ] if ] final-literals
] unit-test

[ V{ 9 } ] [
    [
        >fixnum
        dup 10 < [ dup 8 > [ drop 9 ] unless ] [ drop 9 ] if
    ] final-literals
] unit-test

[ V{ fixnum } ] [
    [
        >fixnum
        dup [ 10 < ] [ -10 > ] bi and not [ 2 * ] unless
    ] final-classes
] unit-test

[ V{ fixnum } ] [
    [ { fixnum } declare (clone) ] final-classes
] unit-test

[ V{ vector } ] [
    [ vector new ] final-classes
] unit-test

[ V{ fixnum } ] [
    [
        [ uchar-nth ] 2keep [ uchar-nth ] 2keep uchar-nth
        >r >r 298 * r> 100 * - r> 208 * - 128 + -8 shift
        255 min 0 max
    ] final-classes
] unit-test
