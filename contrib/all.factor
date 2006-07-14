USING: kernel modules words ;

REQUIRES: aim automata boids cairo concurrency coroutines
crypto dlists embedded gap-buffer httpd math postgresql process
random-tester slate splay-trees sqlite topology units vars ;

"x11" vocab [
    "factory" require
    "x11" require
] when
