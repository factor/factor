USING: arrays kernel make sequences sequences.product tools.test ;
IN: sequences.product.tests


[ { { 0 "a" } { 1 "a" } { 2 "a" } { 0 "b" } { 1 "b" } { 2 "b" } } ]
[ { { 0 1 2 } { "a" "b" } } <product-sequence> >array ] unit-test

[ { { 0 "a" } { 1 "a" } { 2 "a" } { 0 "b" } { 1 "b" } { 2 "b" } } ]
[ { { 0 1 2 } { "a" "b" } } [ ] product-map ] unit-test

[
    {
        { 0 "a" t } { 1 "a" t } { 2 "a" t } { 0 "b" t } { 1 "b" t } { 2 "b" t }
        { 0 "a" f } { 1 "a" f } { 2 "a" f } { 0 "b" f } { 1 "b" f } { 2 "b" f }
    }
] [ { { 0 1 2 } { "a" "b" } { t f } } [ ] product-map ] unit-test

[ "a1b1c1a2b2c2" ] [
    [
        { { "a" "b" "c" } { "1" "2" } }
        [ [ % ] each ] product-each
    ] "" make
] unit-test
