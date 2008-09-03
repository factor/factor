IN: benchmark.euler186
USING: kernel project-euler.186 ;

: euler186-benchmark ( -- )
    euler186 2325629 assert= ;

MAIN: euler186-benchmark
