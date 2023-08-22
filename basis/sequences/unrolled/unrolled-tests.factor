! Copyright (C) 2010 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: compiler.test compiler.tree.debugger kernel make math.parser sequences
sequences.unrolled tools.test ;
IN: sequences.unrolled.tests

{ { "0" "1" "2" } } [ { 0 1 2 } 3 [ number>string ] unrolled-map ] unit-test
{ { "0" "1" "2" } } [ { 0 1 2 } [ 3 [ number>string ] unrolled-map ] compile-call ] unit-test

{ { "0" "1" "2" } } [ [ { 0 1 2 } 3 [ number>string , ] unrolled-each ] { } make ] unit-test
{ { "0" "1" "2" } } [ [ { 0 1 2 } [ 3 [ number>string , ] unrolled-each ] compile-call ] { } make ] unit-test

{ { "a0" "b1" "c2" } }
[ [ { "a" "b" "c" } 3 [ number>string append , ] unrolled-each-index ] { } make ] unit-test

{ { "a0" "b1" "c2" } }
[ [ { "a" "b" "c" } [ 3 [ number>string append , ] unrolled-each-index ] compile-call ] { } make ] unit-test

{ { "aI" "bII" "cIII" } }
[ [ { "a" "b" "c" } { "I" "II" "III" } [ 3 [ append , ] unrolled-2each ] compile-call ] { } make ] unit-test

{ { "aI" "bII" "cIII" } }
[ { "a" "b" "c" } { "I" "II" "III" } 3 [ append ] unrolled-2map ] unit-test

{ { "aI" "bII" "cIII" } }
[ { "a" "b" "c" } { "I" "II" "III" } [ 3 [ append ] unrolled-2map ] compile-call ] unit-test

{ { "a0" "b1" "c2" } }
[ { "a" "b" "c" } 3 [ number>string append ] unrolled-map-index ] unit-test

{ { "a0" "b1" "c2" } }
[ { "a" "b" "c" } [ 3 [ number>string append ] unrolled-map-index ] compile-call ] unit-test

[ { 0 1 2 } 4 [ number>string ] unrolled-map ] [ unrolled-bounds-error? ] must-fail-with
[ { 0 1 2 3 } { 0 1 2 } 4 [ number>string append ] unrolled-2map ] [ unrolled-2bounds-error? ] must-fail-with

{ t }
[ [ 3 [ number>string ] unrolled-map ] { call } inlined? ] unit-test

{ t }
[ [ 3 [ number>string , ] unrolled-each ] { call } inlined? ] unit-test

{ t }
[ [ 3 [ number>string append , ] unrolled-each-index ] { call } inlined? ] unit-test

{ t }
[ [ 3 [ append , ] unrolled-2each ] { call } inlined? ] unit-test

{ t }
[ [ 3 [ append ] unrolled-2map ] { call } inlined? ] unit-test

{ t }
[ [ 3 [ number>string append ] unrolled-map-index ] { call } inlined? ] unit-test
