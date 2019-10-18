! (c)2009 Slava Pestov & Joe Groff, see BSD license
USING: kernel sequences sequences.squish tools.test vectors ;

{ { { 1 2 3 } { 4 } { 5 6 } } } [
    V{ { 1 2 3 } V{ { 4 } { 5 6 } } }
    [ vector? ] { } squish
] unit-test
