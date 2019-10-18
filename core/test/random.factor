IN: temporary
USING: errors kernel math namespaces sequences test ;

: check-random-int ( max -- ? )
    dup >r random-int 0 r> between? ;

[ t ] [ 100 [ drop 674 check-random-int ] all? ] unit-test

: make-100-random-ints
    [ 100 [ 100 random-int , ] times ] { } make ;

[ f ] [ make-100-random-ints make-100-random-ints = ] unit-test
