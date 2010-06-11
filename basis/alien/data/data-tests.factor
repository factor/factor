USING: alien alien.c-types alien.data alien.syntax
classes.struct kernel sequences specialized-arrays
tools.test ;
IN: alien.data.tests

STRUCT: foo { a int } { b void* } { c bool } ;

SPECIALIZED-ARRAY: foo

[ t ] [ 0 binary-zero? ] unit-test
[ f ] [ 1 binary-zero? ] unit-test
[ f ] [ -1 binary-zero? ] unit-test
[ t ] [ 0.0 binary-zero? ] unit-test
[ f ] [ 1.0 binary-zero? ] unit-test
[ f ] [ -0.0 binary-zero? ] unit-test
[ t ] [ C{ 0.0 0.0 } binary-zero? ] unit-test
[ f ] [ C{ 1.0 0.0 } binary-zero? ] unit-test
[ f ] [ C{ -0.0 0.0 } binary-zero? ] unit-test
[ f ] [ C{ 0.0 1.0 } binary-zero? ] unit-test
[ f ] [ C{ 0.0 -0.0 } binary-zero? ] unit-test
[ t ] [ f binary-zero? ] unit-test
[ t ] [ 0 <alien> binary-zero? ] unit-test
[ f ] [ 1 <alien> binary-zero? ] unit-test
[ f ] [ B{ } binary-zero? ] unit-test
[ t ] [ S{ foo f 0 f f } binary-zero? ] unit-test
[ f ] [ S{ foo f 1 f f } binary-zero? ] unit-test
[ f ] [ S{ foo f 0 ALIEN: 8 f } binary-zero? ] unit-test
[ f ] [ S{ foo f 0 f t } binary-zero? ] unit-test
[ t t f ] [
    foo-array{
        S{ foo f 0 f f }
        S{ foo f 0 f f }
        S{ foo f 1 f f }
    } [ first binary-zero? ] [ second binary-zero? ] [ third binary-zero? ] tri
] unit-test
