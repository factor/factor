IN: optimizer.math.partial.tests
USING: optimizer.math.partial tools.test math kernel
sequences ;

[ t ] [ \ + integer fixnum math-both-known? ] unit-test
[ t ] [ \ + bignum fixnum math-both-known? ] unit-test
[ t ] [ \ + integer bignum math-both-known? ] unit-test
[ t ] [ \ + float fixnum math-both-known? ] unit-test
[ f ] [ \ + real fixnum math-both-known? ] unit-test
[ f ] [ \ + object number math-both-known? ] unit-test
[ f ] [ \ number= fixnum object math-both-known? ] unit-test
[ t ] [ \ number= integer fixnum math-both-known? ] unit-test
[ f ] [ \ >fixnum \ shift derived-ops memq? ] unit-test
