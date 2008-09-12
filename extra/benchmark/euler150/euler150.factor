IN: benchmark.euler150
USING: kernel project-euler.150 ;

: euler150-benchmark ( -- )
    euler150 -271248680 assert= ;

MAIN: euler150-benchmark
