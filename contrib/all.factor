USING: kernel modules words ;

REQUIRES: contrib/action-field contrib/alien contrib/automata
contrib/benchmarks contrib/boids contrib/cairo contrib/calendar
contrib/concurrency contrib/coroutines contrib/crypto
contrib/dlists contrib/emacs contrib/embedded contrib/furnace
contrib/furance-pastebin contrib/gap-buffer contrib/hexdump
contrib/http contrib/httpd contrib/http-client contrib/jedit
contrib/jni contrib/json contrib/lambda contrib/lazy-lists
contrib/lindenmayer contrib/match contrib/math
contrib/parser-combinators contrib/postgresql contrib/process
contrib/random-tester contrib/rss contrib/sequences
contrib/serialize contrib/slate contrib/space-invaders
contrib/splay-trees contrib/sqlite contrib/textmate
contrib/topology contrib/units contrib/usb contrib/vars
contrib/vim contrib/xml ;

"x11" vocab [
    "contrib/factory" require
    "contrib/x11" require
] when

"cocoa" vocab [
    "contrib/cocoa-callbacks" require
] when

PROVIDE: contrib/all ;
