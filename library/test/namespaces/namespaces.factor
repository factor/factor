IN: scratchpad
USE: kernel
USE: namespaces
USE: test
USE: stack
USE: words

<namespace> "test-namespace" set

: test-namespace ( -- )
    <namespace> dup [ namespace = ] bind ;

: test-this-1 ( -- )
    <namespace> dup [ this = ] bind ;

[ t ] [ test-namespace ] unit-test
[ t ] [ test-this-1    ] unit-test

! Object paths should not resolve further up in the namestack.

<namespace> "test-namespace" set
[ f ]
[ [ "test-namespace" "test-namespace" ] object-path ]
unit-test

[ f ]
[ [ "alalal" "boobobo" "bah" ] object-path ]
unit-test

[ t ]
[ this [ ] object-path = ]
unit-test

[ t ]
[
    "test-word" intern
    global [ [ "vocabularies" "test" "test-word" ] object-path ] bind
    =
] unit-test

10 "some-global" set
[ f ]
[ <namespace> [ f "some-global" set "some-global" get ] bind ]
unit-test
