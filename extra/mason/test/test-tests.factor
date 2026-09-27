USING: arrays assocs combinators continuations io.directories io.files.temp
kernel mason.common mason.test sequences tools.test ;
IN: mason.test.tests

! Observe the previous checkpoint from inside the next benchmark, before
! the whole phase can finish. Include a benchmark failure and keep going.
{ { { "first" 1000000000 } { "last" 2000000000 } } { "broken" } } [
    [
        { "first" "broken" "last" } [
            {
                { "first" [ 1000000000 ] }
                { "broken" [ "benchmark failed" throw ] }
                { "last" [
                    benchmarks-file eval-file >array
                    { { "first" 1000000000 } } assert=
                    benchmark-error-vocabs-file eval-file { "broken" } assert=
                    2000000000
                ] }
            } case
        ] run-mason-benchmarks
        benchmarks-file eval-file >array
        benchmark-error-vocabs-file eval-file >array
    ] with-temp-directory
] unit-test

{ { } { } } [
    [
        { } [ drop 0 ] run-mason-benchmarks
        benchmarks-file eval-file >array
        benchmark-error-vocabs-file eval-file >array
    ] with-temp-directory
] unit-test
