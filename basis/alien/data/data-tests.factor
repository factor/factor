USING: alien alien.c-types alien.data alien.syntax
classes.struct kernel sequences specialized-arrays
specialized-arrays.private tools.test compiler.units vocabs ;
IN: alien.data.tests


[ -1 ] [ -1 char <ref> char deref ] unit-test
[ -1 ] [ -1 short <ref> short deref ] unit-test
[ -1 ] [ -1 int <ref> int deref ] unit-test

! I don't care if this throws an error or works, but at least
! it should be consistent between platforms
[ -1 ] [ -1.0 int <ref> int deref ] unit-test
[ -1 ] [ -1.0 long <ref> long deref ] unit-test
[ -1 ] [ -1.0 longlong <ref> longlong deref ] unit-test
[ 1 ] [ 1.0 uint <ref> uint deref ] unit-test
[ 1 ] [ 1.0 ulong <ref> ulong deref ] unit-test
[ 1 ] [ 1.0 ulonglong <ref> ulonglong deref ] unit-test

[
    0 B{ 1 2 3 4 } <displaced-alien> void* <ref>
] must-fail

os windows? cpu x86.64? and [
    [ -2147467259 ] [ 2147500037 long <ref> long deref ] unit-test
] when

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

[ ] [
    [
        foo specialized-array-vocab forget-vocab
    ] with-compilation-unit
] unit-test
