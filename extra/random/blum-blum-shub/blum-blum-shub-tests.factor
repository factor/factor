USING: kernel math tools.test namespaces random
random.blum-blum-shub alien.c-types sequences splitting
grouping ;
IN: blum-blum-shub.tests

[ 887708070 ] [
    T{ blum-blum-shub f 590695557939 811977232793 } clone random-32*
] unit-test


[ 70576473 ] [
    T{ blum-blum-shub f 590695557939 811977232793 } clone [
        32 random-bits
    ] with-random
] unit-test

[ 5570804936418322777 ] [
    T{ blum-blum-shub f 590695557939 811977232793 } clone [
        64 random-bits
    ] with-random
] unit-test

[ 3716213681 ]
[
    100 T{ blum-blum-shub f 200352954495 846054538649 } clone tuck [
        random-32* drop
    ] curry times
    random-32*
] unit-test
