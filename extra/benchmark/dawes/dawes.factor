USING: sequences hints kernel math specialized-arrays.int fry ;
IN: benchmark.dawes

! Phil Dawes's performance problem

: count-ones ( int-array -- n ) [ 1 = ] count ; inline

HINTS: count-ones int-array ;

: make-int-array ( -- int-array )
    120000 [ 255 bitand ] int-array{ } map-as ;

: dawes-benchmark ( -- )
    make-int-array 200 swap '[ _ count-ones ] replicate drop ;

MAIN: dawes-benchmark
