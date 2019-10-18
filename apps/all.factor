USING: words kernel modules ;

REQUIRES: apps/automata apps/benchmarks apps/boids
apps/factorbot apps/furnace-fjsc apps/furnace-onigiri
apps/furnace-pastebin apps/help-lint apps/hexdump
apps/lindenmayer apps/lisppaste apps/mandel apps/random-tester
apps/raytracer apps/rss apps/space-invaders apps/tetris
apps/turing apps/show-dataflow apps/wee-url ;

"x11" vocab [
    "apps/factory" require
] when

PROVIDE: apps/all ;
