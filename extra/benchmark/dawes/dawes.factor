USING: sequences hints kernel math specialized-arrays.int ;
IN: benchmark.dawes

! Phil Dawes's performance problem

: count-ones ( byte-array -- n ) [ 1 = ] sigma ;

HINTS: count-ones int-array ;

: make-byte-array ( -- byte-array )
    120000 [ 255 bitand ] int-array{ } map-as ;

: dawes-benchmark ( -- )
    make-byte-array 200 swap [ count-ones ] curry replicate drop ;

MAIN: dawes-benchmark
