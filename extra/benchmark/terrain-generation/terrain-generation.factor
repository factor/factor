! Copyright (C) 2009, 2012 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel math.vectors.simd terrain.generation ;
FROM: alien.c-types => float ;
IN: benchmark.terrain-generation

: terrain-generation-benchmark ( -- )
    <terrain> float-4{ 0 0 0 1 } terrain-segment
    dim>> { 512 512 } assert= ;

MAIN: terrain-generation-benchmark
