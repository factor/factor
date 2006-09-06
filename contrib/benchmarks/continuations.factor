IN: temporary
USING: kernel sequences test ;

[ ] [ 100000 [ drop [ continue ] callcc0 ] each ] unit-test
