IN: scratchpad
USE: kernel
USE: namespaces
USE: test
USE: stack
USE: words

<namespace> "test-namespace" set

: test-namespace ( -- )
    <namespace> dup [ namespace = ] bind ;

[ t ] [ test-namespace ] unit-test

! Object paths should not resolve further up in the namestack.

<namespace> "test-namespace" set
[ f ]
[ [ "test-namespace" "test-namespace" ] object-path ]
unit-test

[ f ]
[ [ "alalal" "boobobo" "bah" ] object-path ]
unit-test

[ t ]
[ namespace [ ] object-path = ]
unit-test

[ t ]
[
    \ test-word
    global [ [ "vocabularies" "test" "test-word" ] object-path ] bind
    =
] unit-test

10 "some-global" set
[ f ]
[ <namespace> [ f "some-global" set "some-global" get ] bind ]
unit-test

[
    5 [ "test" "object" "path" ] set-object-path
    [ 5 ] [ [ "test" "object" "path" ] object-path ] unit-test

    7 [ "test" "object" "pathe" ] set-object-path
    [ 7 ] [ [ "test" "object" "pathe" ] object-path ] unit-test

    9 [ "teste" "object" "pathe" ] set-object-path
    [ 9 ] [ [ "teste" "object" "pathe" ] object-path ] unit-test
] with-scope
