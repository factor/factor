USING: arrays fry kernel math.vectors random sequences ;
IN: benchmark.k-nn

: make-data ( n -- seq )
    [ 784 255 randoms 8 random 2array ] replicate ;

: classify ( training pixels -- label )
    '[ first _ distance ] minimum-by second ;

: validate ( training validation -- n )
    [ first2 [ classify ] [ = ] bi* ] with count ;

: k-nn-benchmark ( -- )
    2,000 make-data 200 make-data validate drop ;

MAIN: k-nn-benchmark
