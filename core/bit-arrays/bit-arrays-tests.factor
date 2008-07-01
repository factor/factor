USING: sequences arrays bit-arrays kernel tools.test math
random ;
IN: bit-arrays.tests

[ 100 ] [ 100 <bit-array> length ] unit-test

[
    { t f t }
] [
    3 <bit-array> t 0 pick set-nth t 2 pick set-nth
    >array
] unit-test

[
    { t f t }
] [
    { t f t } >bit-array >array
] unit-test

[
    { t f t } { f t f }
] [
    { t f t } >bit-array dup clone dup [ not ] change-each
    [ >array ] bi@
] unit-test

[
    { f f f f f }
] [
    { t f t t f } >bit-array dup clear-bits >array
] unit-test

[
    { t t t t t }
] [
    { t f t t f } >bit-array dup set-bits >array
] unit-test

[ t ] [
    100 [
        drop 100 [ 2 random zero? ] replicate
        dup >bit-array >array =
    ] all?
] unit-test

[ ?{ f } ] [
    1 2 { t f t f } <slice> >bit-array
] unit-test

[ ?{ t f t f f f } ] [ 6 ?{ t f t } resize-bit-array ] unit-test

[ ?{ t t } ] [ 2 ?{ t t f t f t f t t t f t } resize-bit-array ] unit-test

[ -10 ?{ } resize-bit-array ] must-fail

[ -1 integer>bit-array ] must-fail
[ ?{ } ] [ 0 integer>bit-array ] unit-test
[ ?{ f t } ] [ 2 integer>bit-array ] unit-test
[ ?{ t t t t t t t t t } ] [ 511 integer>bit-array ] unit-test
[ ?{ 
    t t t t t t t t   t t t t t t t t   t t t t t t t t  t t t t t t t t
    t t t t t t t t   t t t t t t t t   t t t t t t t t  t t t t t t t t
    t t t t t t t t   t t t t t t t t   t t t t t t t t  t t t t t t t t
    t t t t t t t t   t t t t t t t t   t t t t t t t t  t t t t t t t t
} ] [
    HEX: ffffffffffffffffffffffffffffffff integer>bit-array
] unit-test

[ 14 ] [ ?{ f t t t } bit-array>integer ] unit-test
[ 0 ] [ ?{ } bit-array>integer ] unit-test
[ HEX: ffffffffffffffffffffffffffffffff ] [ ?{
    t t t t t t t t   t t t t t t t t   t t t t t t t t  t t t t t t t t
    t t t t t t t t   t t t t t t t t   t t t t t t t t  t t t t t t t t
    t t t t t t t t   t t t t t t t t   t t t t t t t t  t t t t t t t t
    t t t t t t t t   t t t t t t t t   t t t t t t t t  t t t t t t t t
} bit-array>integer ] unit-test
