! (c)Joe Groff bsd license
USING: io kernel terrain.generation threads ;
IN: benchmark.terrain-generation

: terrain-generation-benchmark ( -- )
    "Generating terrain segment..." write flush yield
    <terrain> { 0 0 } terrain-segment drop
    "done" print ;

MAIN: terrain-generation-benchmark
