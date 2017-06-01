USING: arrays kernel literals random sequences ;
IN: benchmark.randomize

CONSTANT: data $[ 10,000,000 <iota> >array ]

: randomize-benchmark ( -- )
    data randomize drop ;

MAIN: randomize-benchmark
