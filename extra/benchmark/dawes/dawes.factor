USING: sequences alien.c-types math hints kernel byte-arrays ;
IN: benchmark.dawes

! Phil Dawes's performance problem

: int-length ( byte-array -- n ) length "int" heap-size /i ; inline

: count-ones ( byte-array -- n )
    0 swap [ int-length ] keep [
        int-nth 1 = [ 1 + ] when
    ] curry each-integer ;

HINTS: count-ones byte-array ;

: make-byte-array ( -- byte-array )
    120000 [ 255 bitand ] map >c-int-array ;

: dawes-benchmark ( -- )
    make-byte-array 200 swap [ count-ones ] curry replicate drop ;

MAIN: dawes-benchmark
