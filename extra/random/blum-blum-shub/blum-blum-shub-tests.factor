USING: kernel math tools.test namespaces random
random.blum-blum-shub ;
IN: blum-blum-shub.tests

[ 887708070 ] [
    T{ blum-blum-shub f 590695557939 811977232793 } random-32*
] unit-test


[ 887708070 ] [
    T{ blum-blum-shub f 590695557939 811977232793 } [
        32 random-bits
    ] with-random
] unit-test

[ 5726770047455156646 ] [
    T{ blum-blum-shub f 590695557939 811977232793 } [
        64 random-bits
    ] with-random
] unit-test

[ 3716213681 ]
[
    100 T{ blum-blum-shub f 200352954495 846054538649 } tuck [
        random-32* drop
    ] curry times
    random-32*
] unit-test
