USING: io io.encodings.ascii io.files io.files.temp math
math.parser kernel sequences ;
IN: benchmark.sum-file

<<
"sum-file.txt" temp-file ascii [
    100000 <iota> [ number>string print ] each
] with-file-writer
>>

: sum-file ( file -- n )
    ascii [ 0 [ string>number + ] each-line ] with-file-reader ;

: sum-file-benchmark ( -- )
    15 [
        "sum-file.txt" temp-file sum-file 4999950000 assert=
    ] times ;

MAIN: sum-file-benchmark
