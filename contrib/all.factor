USING: kernel modules words ;

REQUIRES: automata boids cairo calendar concurrency coroutines
crypto dlists emacs embedded gap-buffer hexdump httpd jedit
json lambda lazy-lists math parser-combinators postgresql
process random-tester slate space-invaders splay-trees sqlite
topology units vars vim ;

"x11" vocab [
    "factory" require
    "x11" require
] when
