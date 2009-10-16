! (c)Joe Groff bsd license
USING: io kernel math.vectors.simd terrain.generation threads ;
FROM: alien.c-types => float ;
SIMD: float
IN: benchmark.terrain-generation

: terrain-generation-benchmark ( -- )
    "Generating terrain segment..." write flush yield
    <terrain> float-4{ 0 0 0 1 } terrain-segment drop
    "done" print ;

MAIN: terrain-generation-benchmark
