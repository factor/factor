IN: temporary
USE: kernel
USE: namespaces
USE: test
USE: words

<namespace> "test-namespace" set

: test-namespace ( -- )
    <namespace> dup [ namespace = ] bind ;

[ t ] [ test-namespace ] unit-test

[
    "nested" off

    "nested" nest [ 5 "x" set ] bind
    [ 5 ] [ "nested" nest [ "x" get ] bind ] unit-test

] with-scope

10 "some-global" set
[ f ]
[ <namespace> [ f "some-global" set "some-global" get ] bind ]
unit-test
