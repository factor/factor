IN: generic.math.tests
USING: generic.math math tools.test kernel ;

! Test math-combination
[ [ [ >float ] dip ] ] [ \ real \ float math-upgrade ] unit-test
[ [ >float ] ] [ \ float \ real math-upgrade ] unit-test
[ [ [ >bignum ] dip ] ] [ \ fixnum \ bignum math-upgrade ] unit-test
[ [ >float ] ] [ \ float \ integer math-upgrade ] unit-test

[ number ] [ number float math-class-max ] unit-test
[ number ] [ float number math-class-max ] unit-test
[ float ] [ real float math-class-max ] unit-test
[ float ] [ float real math-class-max ] unit-test
[ fixnum ] [ fixnum null math-class-max ] unit-test
[ fixnum ] [ null fixnum math-class-max ] unit-test
[ bignum ] [ fixnum bignum math-class-max ] unit-test
[ bignum ] [ bignum fixnum math-class-max ] unit-test
[ number ] [ fixnum number math-class-max ] unit-test
[ number ] [ number fixnum math-class-max ] unit-test


