IN: temporary
USING: kernel math sequences test ;

[ t ] [ 100 [ drop 20 random-int 0 20 between? ] all? ] unit-test
