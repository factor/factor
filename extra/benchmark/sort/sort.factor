USING: kernel sequences sorting benchmark.random math.parser
io.files ;
IN: benchmark.sort

: sort-benchmark
    random-numbers-path file-lines [ string>number ] map natural-sort drop ;

MAIN: sort-benchmark
