IN: temporary
USING: compiler kernel math sequences test ;

: sort-benchmark
    100000 [ drop 100000 random-int ] map natural-sort drop ; compiled

[ ] [ sort-benchmark ] unit-test
