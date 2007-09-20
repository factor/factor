USING: kernel math random namespaces sequences tools.test ;
IN: temporary

: check-random ( max -- ? )
    dup >r random 0 r> between? ;

[ t ] [ 100 [ drop 674 check-random ] all? ] unit-test

: make-100-randoms
    [ 100 [ 100 random , ] times ] { } make ;

[ f ] [ make-100-randoms make-100-randoms = ] unit-test

[ 1333075495 ] [ 0 init-random 1000 [ drop (random) drop ] each (random) ] unit-test
[ 1575309035 ] [ 0 init-random 10000 [ drop (random) drop ] each (random) ] unit-test
