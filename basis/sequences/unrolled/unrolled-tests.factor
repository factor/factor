! (c)2010 Joe Groff bsd license
USING: compiler.test make math.parser sequences
sequences.unrolled tools.test ;
IN: sequences.unrolled.tests

[ { "0" "1" "2" } ] [ { 0 1 2 } 3 [ number>string ] unrolled-map ] unit-test
[ { "0" "1" "2" } ] [ { 0 1 2 } [ 3 [ number>string ] unrolled-map ] compile-call ] unit-test

[ { "0" "1" "2" } ] [ [ { 0 1 2 } 3 [ number>string , ] unrolled-each ] { } make ] unit-test

[ { "a0" "b1" "c2" } ]
[ [ { "a" "b" "c" } 3 [ number>string append , ] unrolled-each-index ] { } make ] unit-test

[ { "aI" "bII" "cIII" } ]
[ [ { "a" "b" "c" } { "I" "II" "III" } 3 [ append , ] unrolled-2each ] { } make ] unit-test

[ { "aI" "bII" "cIII" } ]
[ { "a" "b" "c" } { "I" "II" "III" } 3 [ append ] unrolled-2map ] unit-test

[ { "a0" "b1" "c2" } ]
[ { "a" "b" "c" } 3 [ number>string append ] unrolled-map-index ] unit-test

[ { 0 1 2 } 4 [ number>string ] unrolled-map ] [ unrolled-bounds-error? ] must-fail-with
[ { 0 1 2 3 } { 0 1 2 } 4 [ number>string append ] unrolled-2map ] [ unrolled-2bounds-error? ] must-fail-with
