IN: temporary

! Various things that broke CFactor at various times.
USING: errors kernel lists math memory namespaces parser
prettyprint sequences strings test vectors words ;

[ ] [
    "20 <sbuf> \"foo\" set" eval
    "garbage-collection" eval
] unit-test

[ ] [
    [
        [ drop ] [ drop ] catch
        [ drop ] [ drop ] catch
    ] keep-datastack
] unit-test

[ ] [ 10 [ [ -1000000 <vector> ] [ drop ] catch ] times ] unit-test
[ ] [ 10 [ [ -1000000 <sbuf> ] [ drop ] catch ] times ] unit-test

! See how well callstack overflow is handled
: callstack-overflow callstack-overflow f ;
[ callstack-overflow ] unit-test-fails

! Weird PowerPC bug.
[ ] [
    [ "4" throw ] [ drop ] catch
    garbage-collection
    garbage-collection
] unit-test
