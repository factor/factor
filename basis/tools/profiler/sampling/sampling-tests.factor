USING: assocs byte-arrays calendar kernel kernel.private math memory
namespaces parser random sequences threads tools.profiler.sampling
tools.profiler.sampling.private tools.test ;
IN: tools.profiler.sampling.tests

! collect-tops: top is the last element in the array
{ 5 } [
    { { 1 2 3 4 5 6 { 3 4 5 } } } 1 2 collect-tops
    keys first
] unit-test

! Make sure the profiler doesn't blow up the VM
TUPLE: boom ;
{ } [ 10 [ [ ] profile ] times ] unit-test
[ 10 [ [ boom new throw ] profile ] times ] [ boom? ] must-fail-with
{ } [ 10 [ [ 100 [ 1000 random (byte-array) drop ] times gc ] profile ] times ] unit-test
{ } [ 10 [ [ 100 [ 1000 random (byte-array) drop ] times compact-gc ] profile ] times ] unit-test
{ } [ 2 [ [ 1 seconds sleep ] profile ] times ] unit-test

{ } [ [ 300,000 <iota> [ sq sq sq ] map drop ] profile flat profile. ] unit-test
{ } [ [ 300,000 <iota> [ sq sq sq ] map drop ] profile top-down profile. ] unit-test

f raw-profile-data set-global
gc

{ t t } [
    ! Seed the samples data
    [ "resource:basis/tools/memory/memory.factor" run-file ] profile
    (get-samples) length 0 >
    OBJ-SAMPLE-CALLSTACKS special-object first 0 >
] unit-test

{ t } [
    ! On x86.64, [ ] profile doesn't generate any samples at all
    ! because it runs so quickly. On x86.32, one spurious sample is
    ! sometimes generated for some unknown reason.
    gc [ ] profile (get-samples) length 1 <=
] unit-test
