USING: words kernel modules ;

REQUIRES: apps/automata apps/benchmarks apps/boids
apps/factorbot apps/furnace-pastebin apps/hexdump
apps/lindenmayer apps/mandel apps/random-tester apps/raytracer
apps/rss apps/space-invaders apps/tetris apps/turing ;

"x11" vocab [
    "apps/factory" require
] when

PROVIDE: apps/all ;
