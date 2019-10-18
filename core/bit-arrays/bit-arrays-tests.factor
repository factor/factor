USING: sequences arrays bit-arrays kernel tools.test math
random ;
IN: temporary

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
    [ >array ] 2apply
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
        drop 100 [ drop 2 random zero? ] map
        dup >bit-array >array =
    ] all?
] unit-test

[ ?{ f } ] [
    1 2 { t f t f } <slice> >bit-array
] unit-test
