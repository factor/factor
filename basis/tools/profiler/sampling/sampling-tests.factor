USING: assocs byte-arrays calendar continuations io.streams.string
kernel kernel.private math math.parser memory namespaces parser
random sequences splitting threads
tools.profiler.sampling tools.profiler.sampling.private
tools.test ;
IN: tools.profiler.sampling.tests

CONSTANT: report-samples {
    { 60 0 0 0 0 "thread-a" { "expensive" "caller" } }
    { 10 0 0 0 0 "thread-a" { "cheap" "caller" } }
    { 30 0 0 0 0 "thread-b" { "other" } }
}

: report-percentages ( -- percentages )
    [ report-samples top-down* profile. ] with-string-writer
    split-lines rest [ empty? ] reject
    [ split-words harvest third string>number ] map ;

! All rows use total time across threads, even after root trimming (#385).
{ { 70.0 60.0 10.0 30.0 30.0 } } [ report-percentages ] unit-test

! The cutoff is inclusive and does not renormalize the remaining rows.
{ { 70.0 60.0 30.0 30.0 } } [
    30 profile-minimum-percent [ report-percentages ] with-variable
] unit-test

{ { } } [
    90 profile-minimum-percent [ report-percentages ] with-variable
] unit-test

! Empty and zero-time profiles still print without NaNs or division by zero.
{ 0.0 } [ 0 0 time-percentage ] unit-test
{ t } [
    [ H{ } profile. ] with-string-writer
    "time %" swap subseq?
] unit-test

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

! On Unix this used to put 1,000,000 in tv_usec, silently disabling the timer.
{ t } [
    1 set-profiling
    [ 2 seconds sleep ] [ 0 set-profiling ] finally
    get-samples >boolean
] unit-test
