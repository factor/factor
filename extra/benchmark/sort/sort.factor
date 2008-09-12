USING: kernel sequences sorting benchmark.random math.parser
io.files io.encodings.ascii ;
IN: benchmark.sort

: sort-benchmark ( -- )
    random-numbers-path
    ascii file-lines [ string>number ] map
    natural-sort drop ;

MAIN: sort-benchmark
