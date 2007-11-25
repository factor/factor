USING: io io.files math math.parser kernel prettyprint ;
IN: benchmark.sum-file

: sum-file-loop ( n -- n' )
    readln [ string>number + sum-file-loop ] when* ;

: sum-file ( file -- )
    <file-reader> [ 0 sum-file-loop ] with-stream . ;

: sum-file-main ( -- )
    home "sum-file-in.txt" path+ sum-file ;

MAIN: sum-file-main
