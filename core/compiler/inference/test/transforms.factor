IN: temporary
USING: arrays inference test math kernel quotations ;

: compose-n-quot <array> >quotation ;
: compose-n compose-n-quot call ;
\ compose-n 2 [ compose-n-quot ] define-transform
: compose-n-test 2 \ + compose-n ;

[ 6 ] [ 1 2 3 compose-n-test ] unit-test
