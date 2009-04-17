USING: io io.files math math.parser kernel prettyprint
benchmark.random io.encodings.ascii ;
IN: benchmark.sum-file

: sum-file-loop ( n -- n' )
    readln [ string>number + sum-file-loop ] when* ;

: sum-file ( file -- )
    ascii [ 0 sum-file-loop ] with-file-reader . ;

: sum-file-main ( -- )
    5 [ random-numbers-path sum-file ] times ;

MAIN: sum-file-main
