IN: scratchpad
USE: arithmetic
USE: combinators
USE: compiler
USE: inspector
USE: kernel
USE: lists
USE: logic
USE: namespaces
USE: random
USE: stack
USE: stdio
USE: strings
USE: test
USE: words
USE: vocabularies

"Namespace tests." print

[ t ] [ global [ "global" get ] bind global ] [ = ] test-word
[ [ 1 0 0 0 ] ] [ [ >n ] ] [ balance>list ] test-word
[ [ 1 1 0 0 ] ] [ [ get ] ] [ balance>list ] test-word
[ [ 2 0 0 0 ] ] [ [ set ] ] [ balance>list ] test-word
[ [ 0 1 0 0 ] ] [ [ namestack* ] ] [ balance>list ] test-word
[ [ 0 1 0 0 ] ] [ [ namestack ] ] [ balance>list ] test-word
[ [ 1 0 0 0 ] ] [ [ set-namestack* ] ] [ balance>list ] test-word
[ [ 1 0 0 0 ] ] [ [ set-namestack ] ] [ balance>list ] test-word
[ [ 0 1 0 0 ] ] [ [ n> ] ] [ balance>list ] test-word

<namespace> "test-namespace" set

: test-namespace ( -- )
    <namespace> dup [ namespace = ] bind ;

: test-this-1 ( -- )
    <namespace> dup [ this = ] bind ;

: test-this-2 ( -- )
    interpreter dup [ this = ] bind ;

[ t ] [   ] [ test-namespace ] test-word
[ t ] [   ] [ test-this-1    ] test-word
[ t ] [   ] [ test-this-2    ] test-word

! These stress-test a lot of code.
global describe
"vocabularies" get describe

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

! Object paths should not resolve further up in the namestack.

<namespace> "test-namespace" set
[ f ]
[ [ "test-namespace" "test-namespace" ] ]
[ object-path ]
test-word

[ f ]
[ [ "alalal" "boobobo" "bah" ] ]
[ object-path ]
test-word

[ t ]
[ this [ ] ]
[ object-path  = ]
test-word

[ t ]
[ "test-word" intern [ "global" "vocabularies" "test" "test-word" ] ]
[ object-path  = ]
test-word

10 "some-global" set
[ f ]
[ ]
[ <namespace> [ f "some-global" set "some-global" get ] bind ]
test-word

"Namespace tests passed." print
