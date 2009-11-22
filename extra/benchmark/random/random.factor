USING: io io.files io.files.temp io.encodings.ascii random
math.parser math ;
IN: benchmark.random

: random-numbers-path ( -- path )
    "random-numbers.txt" temp-file ;

: write-random-numbers ( n -- )
    random-numbers-path ascii [
        [ 200 random 100 - number>string print ] times
    ] with-file-writer ;

: random-main ( -- )
    300000 write-random-numbers ;

MAIN: random-main
