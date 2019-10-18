IN: temporary
USING: arrays inference test math kernel compiler ;

: compose-n-quot <array> >quotation ;
: compose-n compose-n-quot call ;
\ compose-n 2 [ compose-n-quot ] define-transform
[ 6 ] [ 1 2 3 [ 2 \ + compose-n ] compile-1 ] unit-test
