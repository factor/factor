USING: fry io.encodings.string io.encodings.utf8 kernel math
random strings ;
IN: benchmark.utf8

: utf8-benchmark ( -- )
    100,000 0xffff randoms >string
    1,000 swap '[ _ dup utf8 encode utf8 decode assert= ] times ;

MAIN: utf8-benchmark
