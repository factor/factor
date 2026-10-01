USING: benchmark.spawn-cat tools.test ;
IN: benchmark.spawn-cat.tests

! Reading a nonempty file must succeed with output discarded, including
! on Windows where +closed+ must discard writes without a broken pipe.
{ } [
    "resource:extra/benchmark/spawn-cat/spawn-cat.factor" 1 spawn-cat
] unit-test
