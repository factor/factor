USING: kernel modules words ;

REQUIRES: automata boids cairo calendar concurrency coroutines
crypto dlists embedded gap-buffer hexdump httpd math postgresql
process random-tester slate splay-trees sqlite topology units
vars ;

"x11" vocab [
    "factory" require
    "x11" require
] when
