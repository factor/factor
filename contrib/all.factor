USING: kernel modules words ;

REQUIRES: contrib/automata contrib/boids contrib/cairo
contrib/calendar contrib/concurrency contrib/coroutines
contrib/crypto contrib/dlists contrib/emacs contrib/embedded
contrib/gap-buffer contrib/hexdump contrib/httpd contrib/jedit
contrib/json contrib/lambda contrib/lazy-lists contrib/math
contrib/parser-combinators contrib/postgresql contrib/process
contrib/random-tester contrib/rss contrib/serialize
contrib/slate contrib/space-invaders contrib/splay-trees
contrib/sqlite contrib/topology contrib/units contrib/vars
contrib/vim ;

"x11" vocab [
    "contrib/factory" require
    "contrib/x11" require
] when
