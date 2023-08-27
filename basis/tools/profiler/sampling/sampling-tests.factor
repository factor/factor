USING: assocs byte-arrays calendar kernel kernel.private math
memory namespaces parser random sequences threads
tools.profiler.sampling tools.profiler.sampling.private
tools.test ;
IN: tools.profiler.sampling.tests

! collect-tops: top is the last element in the array
{ 5 } [
    { { 1 2 3 4 5 6 { 3 4 5 } } } 1 2 collect-tops
    keys first
] unit-test

! Make sure the profiler doesn't blow up the VM
{ } [ 10 [ [ ] profile ] times ] unit-test
TUPLE: boom ;
[ 10 [ [ boom new throw ] profile ] times ] [ boom? ] must-fail-with

{ t t t t t t t t t t } [
    10 [
        [
            100 [ 1000 random (byte-array) >boolean t assert= ] times gc
        ] profile raw-profile-data get-global >boolean
    ] times
] unit-test

{ t t t t t t t t t t } [
    10 [
        [
            100 [ 1000 random (byte-array) >boolean t assert= ] times compact-gc
        ] profile raw-profile-data get-global >boolean
    ] times
] unit-test

{ t t } [
    2 [
        [ 1 seconds sleep ] profile
        raw-profile-data get-global >boolean
    ] times
] unit-test

{ t } [
    [ 1,000,000 <iota> [ sq sq sq ] map >boolean t assert= ] profile
    raw-profile-data get-global >boolean
] unit-test

f raw-profile-data set-global
gc

{ t t } [
    ! Seed the samples data
    [ "resource:basis/tools/memory/memory.factor" run-file ] profile
    get-samples length 0 >
    OBJ-SAMPLE-CALLSTACKS special-object first 0 >
] unit-test

{ t } [
    ! On x86.64, [ ] profile doesn't generate any samples at all
    ! because it runs so quickly. On x86.32, one spurious sample is
    ! sometimes generated for some unknown reason.
    gc [ ] profile get-samples length 1 <=
] unit-test
