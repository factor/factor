IN: temporary
USING: sequences inference.transforms tools.test math kernel
quotations ;

: compose-n-quot <repetition> >quotation ;
: compose-n compose-n-quot call ;
\ compose-n [ compose-n-quot ] 2 define-transform
: compose-n-test 2 \ + compose-n ;

[ 6 ] [ 1 2 3 compose-n-test ] unit-test

[ 0 ] [ { } bitfield-quot call ] unit-test

[ 256 ] [ 1 { 8 } bitfield-quot call ] unit-test

[ 268 ] [ 3 1 { 8 2 } bitfield-quot call ] unit-test

[ 268 ] [ 1 { 8 { 3 2 } } bitfield-quot call ] unit-test

[ 512 ] [ 1 { { 1+ 8 } } bitfield-quot call ] unit-test
