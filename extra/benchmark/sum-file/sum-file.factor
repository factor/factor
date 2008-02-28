USING: io io.files math math.parser kernel prettyprint
benchmark.random ;
IN: benchmark.sum-file

: sum-file-loop ( n -- n' )
    readln [ string>number + sum-file-loop ] when* ;

: sum-file ( file -- )
    [ 0 sum-file-loop ] with-file-reader . ;

: sum-file-main ( -- )
    random-numbers-path sum-file ;

MAIN: sum-file-main
