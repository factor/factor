USING: fry io.encodings.string io.encodings.utf16 kernel math
random strings ;
IN: benchmark.utf16

: utf16-benchmark ( -- )
    100,000 0xff randoms >string
    1,000 swap '[ _ dup utf16 encode utf16 decode assert= ] times ;

MAIN: utf16-benchmark
