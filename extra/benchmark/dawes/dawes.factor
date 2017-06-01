USING: alien.c-types sequences kernel math specialized-arrays
fry ;
SPECIALIZED-ARRAY: int
IN: benchmark.dawes

! Phil Dawes's performance problem

: count-ones ( int-array -- n ) [ 1 = ] count ; inline

: make-int-array ( -- int-array )
    120000 <iota> [ 255 bitand ] int-array{ } map-as ; inline

: dawes-benchmark ( -- )
    200 make-int-array '[ _ count-ones ] replicate drop ;

MAIN: dawes-benchmark
