IN: temporary
USE: kernel
USE: namespaces
USE: test
USE: words

{{ }} clone "test-namespace" set

: test-namespace ( -- )
    {{ }} clone dup [ namespace = ] bind ;

[ t ] [ test-namespace ] unit-test

[
    "nested" off

    "nested" nest [ 5 "x" set ] bind
    [ 5 ] [ "nested" nest [ "x" get ] bind ] unit-test

] with-scope

10 "some-global" set
[ f ]
[ {{ }} clone [ f "some-global" set "some-global" get ] bind ]
unit-test
