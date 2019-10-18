USING: kernel modules words ;

REQUIRES: libs/alarms libs/alien libs/base64
libs/basic-authentication libs/cairo libs/calendar libs/circular
libs/concurrency libs/coroutines libs/crypto libs/csv
libs/dlists libs/editpadpro libs/emacs libs/farkup libs/fjsc
libs/furnace libs/gap-buffer libs/hardware-info libs/heap
libs/hexdump libs/http libs/http-client libs/null-stream
libs/jedit libs/jni libs/json libs/levenshtein libs/lazy-lists
libs/match libs/math libs/matrices libs/mysql libs/odbc
libs/openal libs/parser-combinators libs/porter-stemmer
libs/postgresql libs/process libs/sequences libs/serialize
libs/server libs/shuffle libs/splay-trees libs/sqlite
libs/stack-display libs/state-parser libs/textmate libs/koszul
libs/units libs/unicode libs/usb libs/vars libs/vim libs/xml
libs/xml-rpc libs/yahoo libs/csv libs/null-stream libs/regexp
libs/trees libs/vocabs libs/canvas ;

"cocoa" vocab [
    "libs/cocoa-callbacks" require
] when

PROVIDE: libs/all ;
