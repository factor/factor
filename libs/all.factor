USING: kernel modules words ;

REQUIRES: libs/alien libs/base64 libs/cairo
libs/calendar libs/concurrency libs/coroutines libs/crypto
libs/dlists libs/emacs libs/fjsc libs/furnace libs/gap-buffer
libs/google-search libs/hardware-info libs/http libs/httpd libs/http-client
libs/jedit libs/jni libs/json libs/lambda libs/levenshtein 
libs/lazy-lists libs/match libs/math libs/parser-combinators
libs/porter-stemmer libs/postgresql libs/process
libs/sequences libs/serialize libs/shuffle
libs/slate libs/splay-trees libs/sqlite libs/textmate
libs/topology libs/units libs/usb libs/vars libs/vim libs/xml
libs/xml-rpc ;

"x11" vocab [
    "libs/x11" require
] when

"cocoa" vocab [
    "libs/cocoa-callbacks" require
] when

PROVIDE: libs/all ;
