USING: benchmark kernel sequences tools.test ;
IN: benchmark.tests

: dummy-benchmark ( -- )
    ;

MAIN: dummy-benchmark

{ "benchmark.tests" } [
    { "benchmark.tests" } [ run-timing-benchmark ] run-benchmarks
    drop first first
] unit-test

{ 0 1 } [
    { "benchmark.tests" } [ drop "hello" throw ] run-benchmarks
    2length
] unit-test
