USING: assocs kernel literals math random sequences sorting ;
IN: benchmark.sort

CONSTANT: numbers-to-sort $[ 300,000 200 randoms ]
CONSTANT: alist-to-sort $[ 1,000 <iota> dup zip ]

: sort-benchmark ( -- )
    10 [ numbers-to-sort sort drop ] times
    5,000 [ alist-to-sort sort-keys drop ] times ;

MAIN: sort-benchmark
