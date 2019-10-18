IN: temporary
USING: compiler kernel math sequences test ;

: sort-benchmark
    100000 [ drop 0 10000 random-int ] map number-sort drop ; compiled

[ ] [ sort-benchmark ] unit-test
