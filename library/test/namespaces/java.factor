IN: scratchpad
USE: arithmetic
USE: compiler
USE: kernel
USE: namespaces
USE: stack
USE: test
USE: words
USE: vocabularies

[ [ 1 0 0 0 ] ] [ [ >n ] ] [ balance>list ] test-word
[ [ 1 1 0 0 ] ] [ [ get ] ] [ balance>list ] test-word
[ [ 2 0 0 0 ] ] [ [ set ] ] [ balance>list ] test-word
[ [ 0 1 0 0 ] ] [ [ namestack* ] ] [ balance>list ] test-word
[ [ 0 1 0 0 ] ] [ [ namestack ] ] [ balance>list ] test-word
[ [ 1 0 0 0 ] ] [ [ set-namestack* ] ] [ balance>list ] test-word
[ [ 1 0 0 0 ] ] [ [ set-namestack ] ] [ balance>list ] test-word
[ [ 0 1 0 0 ] ] [ [ n> ] ] [ balance>list ] test-word

: test-this-2 ( -- )
    interpreter dup [ this = ] bind ;

[ t ] [ test-this-2 ] unit-test

: namespace-compile ( x -- x )
    <namespace> [ "x" set ] extend [ "x" get ] bind ; word must-compile

[ 12 ] [ 12 ] [ namespace-compile ] test-word

! A compiler bug in tailcalls that manifests with the namestack

: namespace-tail-call-bug ( x -- x )
    dup 0 = [
        drop
    ] [
        pred <namespace> [ dup "x" set namespace-tail-call-bug ] bind
    ] ifte ; word must-compile

[ f ] [ ] [ 10 namespace-tail-call-bug "x" get 0 = ] test-word

! I did a n> in extend and forgot the obvious case
[ t ] [ "dup" intern dup ] [ [ ] extend = ] test-word
