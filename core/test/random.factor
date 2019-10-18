IN: temporary
USING: errors kernel math namespaces sequences test ;

: check-random ( max -- ? )
    dup >r random 0 r> between? ;

[ t ] [ 100 [ drop 674 check-random ] all? ] unit-test

: make-100-randoms
    [ 100 [ 100 random , ] times ] { } make ;

[ f ] [ make-100-randoms make-100-randoms = ] unit-test
