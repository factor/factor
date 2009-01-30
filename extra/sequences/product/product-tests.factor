USING: arrays kernel sequences sequences.cartesian-product tools.test ;
IN: sequences.product.tests

[
    { { 0 "a" } { 1 "a" } { 2 "a" } { 0 "b" } { 1 "b" } { 2 "b" } }
] [ { { 0 1 2 } { "a" "b" } } [ ] cartesian-product-map ] unit-test

[
    {
        { 0 "a" t } { 1 "a" t } { 2 "a" t } { 0 "b" t } { 1 "b" t } { 2 "b" t }
        { 0 "a" f } { 1 "a" f } { 2 "a" f } { 0 "b" f } { 1 "b" f } { 2 "b" f }
    }
] [ { { 0 1 2 } { "a" "b" } { t f } } [ ] cartesian-product-map ] unit-test

[
    { "012012" "aaabbb" }
] [ { { "0" "1" "2" } { "a" "b" } } [ [ first2 ] bi* [ append ] bi@ 2array ] cartesian-product-each ] unit-test


