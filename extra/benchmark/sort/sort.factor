USING: io.files io.encodings.ascii kernel math math.parser
random sequences sorting ;
IN: benchmark.sort

: sort-benchmark ( -- )
    10 300000 200 random-integers
    [ natural-sort drop ] curry times ;

MAIN: sort-benchmark
