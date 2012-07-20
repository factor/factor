USING: math kernel accessors ;
IN: benchmark.typecheck1

TUPLE: hello n ;

: foo ( obj -- obj n ) 0 100000000 [ over n>> + ] times ;

: typecheck1-benchmark ( -- ) 0 hello boa foo 2drop ;

MAIN: typecheck1-benchmark
