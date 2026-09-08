USING: kernel literals math math.parser random
sequences ;
IN: benchmark.parse-float

<<
: random-finite-float ( -- x )
    64 random-bits bits>double
    dup fp-special? [ drop random-finite-float ] when ;
>>

CONSTANT: test-unit-floats $[ 100,000 random-units ]
CONSTANT: test-floats $[ 100,000 [ random-finite-float ] replicate ]

: parse-floats ( floats -- )
    [ [ number>string string>number ] keep fp-bitwise= t assert= ] each ;

: parse-float-benchmark ( -- )
    test-floats parse-floats ;

: parse-unit-float-benchmark ( -- )
    test-unit-floats parse-floats ;

MAIN: parse-float-benchmark
