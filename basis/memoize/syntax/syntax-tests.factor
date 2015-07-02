USING: calendar math.order memoize.syntax sequences threads
tools.test tools.time ;

IN: memoize.syntax.tests

[ t ] [
    { 1/8 1/8 1/8 1/8 1/16 1/16 1/16 }
    [ MEMO[ seconds sleep ] each ] benchmark
    0.18e9 0.25e9 between?
] unit-test
