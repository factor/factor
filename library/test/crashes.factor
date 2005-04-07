IN: temporary

! Various things that broke CFactor at various times.
USING: errors kernel lists math memory namespaces parser
prettyprint sequences strings test vectors words ;

"20 <sbuf> \"foo\" set" eval
"garbage-collection" eval

[
    [ drop ] [ drop ] catch
    [ drop ] [ drop ] catch
] keep-datastack

10 <vector> "x" set
[ "x" get clone drop ] [ drop ] catch

10 [ [ -1000000 <vector> ] [ drop ] catch ] times

10 [ [ -1000000 <sbuf> ] [ drop ] catch ] times

! Make sure various type checks don't run into header untagging
! problems etc.

! Lotype -vs- lotype
[ ] [ [ 4 car ] [ drop ] catch ] unit-test

! Lotype -vs- hitype
[ ] [ [ 4 vector-length ] [ drop ] catch ] unit-test
[ ] [ [ [ 4 3 ] vector-length ] [ drop ] catch ] unit-test

! Hitype -vs- lotype
[ ] [ [ "hello" car ] [ drop ] catch ] unit-test

! Hitype -vs- hitype
[ ] [ [ "hello" vector-length ] [ drop ] catch ] unit-test

! f -vs- hitype
[ ] [ [ f vector-length ] [ drop ] catch ] unit-test

! See how well callstack overflow is handled
: callstack-overflow callstack-overflow f ;
[ callstack-overflow ] unit-test-fails

[ [ cdr cons ] word-props ] unit-test-fails

! Forgot to tag out of bounds index
[ 1 { } vector-nth ] [ garbage-collection drop ] catch
[ -1 { } set-length ] [ garbage-collection drop ] catch
[ 1 "" string-nth ] [ garbage-collection drop ] catch

! ... and again
[ "" 10 string/ ] [ . ] catch

! Weird PowerPC bug.
[ "4" throw ] [ drop ] catch
garbage-collection
garbage-collection
