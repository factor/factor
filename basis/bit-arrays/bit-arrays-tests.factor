USING: alien arrays bit-arrays kernel math random sequences
sequences.private tools.test ;

[ -1 <bit-array> ] [ T{ bad-array-length f -1 } = ] must-fail-with

{ 100 } [ 100 <bit-array> length ] unit-test

{
    { t f t }
} [
    3 <bit-array> t 0 pick set-nth t 2 pick set-nth
    >array
] unit-test

{
    { t f t }
} [
    { t f t } >bit-array >array
] unit-test

{
    { t f t } { f t f }
} [
    { t f t } >bit-array dup clone [ not ] map!
    [ >array ] bi@
] unit-test

{
    { f f f f f }
} [
    { t f t t f } >bit-array dup clear-bits >array
] unit-test

{
    { t t t t t }
} [
    { t f t t f } >bit-array dup set-bits >array
] unit-test

{ t } [
    100 [
        drop 100 [ 2 random zero? ] replicate
        dup >bit-array >array =
    ] all-integers?
] unit-test

{ ?{ f } } [
    1 2 { t f t f } <slice> >bit-array
] unit-test

{ ?{ f t } } [ 0 2 ?{ f t f } subseq ] unit-test

{ ?{ t f t f f f } } [ 6 ?{ t f t } resize ] unit-test

{ ?{ t t } } [ 2 ?{ t t f t f t f t t t f t } resize ] unit-test

[ -10 ?{ } resize ] must-fail

[ -1 integer>bit-array ] must-fail
{ ?{ } } [ 0 integer>bit-array ] unit-test
{ ?{ f t } } [ 2 integer>bit-array ] unit-test
{ ?{ t t t t t t t t t } } [ 511 integer>bit-array ] unit-test
{ ?{
    t t t t t t t t   t t t t t t t t   t t t t t t t t  t t t t t t t t
    t t t t t t t t   t t t t t t t t   t t t t t t t t  t t t t t t t t
    t t t t t t t t   t t t t t t t t   t t t t t t t t  t t t t t t t t
    t t t t t t t t   t t t t t t t t   t t t t t t t t  t t t t t t t t
} } [
    0xffffffffffffffffffffffffffffffff integer>bit-array
] unit-test

{ 14 } [ ?{ f t t t } bit-array>integer ] unit-test
{ 0 } [ ?{ } bit-array>integer ] unit-test
{ 0xffffffffffffffffffffffffffffffff } [ ?{
    t t t t t t t t   t t t t t t t t   t t t t t t t t  t t t t t t t t
    t t t t t t t t   t t t t t t t t   t t t t t t t t  t t t t t t t t
    t t t t t t t t   t t t t t t t t   t t t t t t t t  t t t t t t t t
    t t t t t t t t   t t t t t t t t   t t t t t t t t  t t t t t t t t
} bit-array>integer ] unit-test

{ 49 } [ 49 <bit-array> dup set-bits [ ] count ] unit-test

{ 1 } [ ?{ f t f t } byte-length ] unit-test

{ 0xa } [ ?{ f t f t } bit-array>integer ] unit-test

{ 0x100 } [ ?{ f f f f f f f f t } bit-array>integer ] unit-test

{ t } [
    2 B{ 0b011 } bit-array boa
    2 B{ 0b111 } bit-array boa =
] unit-test

{ f } [
    3 B{ 0b0 } bit-array boa
    2 B{ 0b0 } bit-array boa =
] unit-test
