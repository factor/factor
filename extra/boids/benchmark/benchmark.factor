USING: arrays boids.simulation io kernel locals math namespaces
prettyprint random random.mersenne-twister sequences sorting tools.time ;
IN: boids.benchmark

<PRIVATE

: benchmark-behaviors ( -- behaviors )
    1.0 75.0 -0.1 <cohesion>
    1.0 40.0 -0.5 <alignment>
    1.0 25.0 -1.0 <separation> 3array ;

:: benchmark-flock ( population dim -- boids )
    12345 <mersenne-twister> random-generator
    [ population dim random-boids-in ] with-variable ;

:: benchmark-case ( population dim iterations -- )
    population dim benchmark-flock :> flock
    benchmark-behaviors :> behaviors
    3 [ flock behaviors 5.0 dim simulate-in drop ] times
    5 [
        [ iterations [ flock behaviors 5.0 dim simulate-in drop ] times ] benchmark
        iterations /f 1,000,000 /f
    ] replicate natural-sort third :> milliseconds
    population dim milliseconds 3array . flush ;

PRIVATE>

: boids-benchmark ( -- )
    "{ population dimensions median-milliseconds-per-step }" print
    100 { 512 512 } 50 benchmark-case
    200 { 512 512 } 20 benchmark-case
    1000 { 512 512 } 2 benchmark-case
    100 { 2048 1536 } 50 benchmark-case
    200 { 2048 1536 } 20 benchmark-case
    1000 { 2048 1536 } 2 benchmark-case
    200 { 64 64 } 10 benchmark-case ;

MAIN: boids-benchmark
