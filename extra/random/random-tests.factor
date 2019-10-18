USING: kernel math random namespaces sequences tools.test ;
IN: temporary

: check-random ( max -- ? )
    dup >r random 0 r> between? ;

[ t ] [ 100 [ drop 674 check-random ] all? ] unit-test

: make-100-randoms
    [ 100 [ 100 random , ] times ] { } make ;

[ f ] [ make-100-randoms make-100-randoms = ] unit-test

[ 708 ] [ 0 init-random 1000 [ random drop ] each 1000 random ] unit-test
[ 359 ] [ 0 init-random 10000 [ random drop ] each 1000 random ] unit-test
