USING: io.files io.encodings.ascii kernel literals math
math.parser random sequences sorting ;
IN: benchmark.sort

CONSTANT: numbers-to-sort $[ 300,000 200 random-integers ]

: sort-benchmark ( -- )
    10 [ numbers-to-sort natural-sort drop ] times ;

MAIN: sort-benchmark
