! Copyright (C) 2010 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors cursors kernel make math sequences sorting tools.test ;
FROM: cursors => each map assoc-each assoc>map ;
IN: cursors.tests

{ { 1 2 3 4 } } [
    [ T{ linear-cursor f 1 1 } T{ linear-cursor f 5 1 } [ value>> , ] -each ]
    { } make
] unit-test

{ T{ linear-cursor f 3 1 } } [
    T{ linear-cursor f 1 1 } T{ linear-cursor f 5 1 } [ value>> 3 mod zero? ] -find
] unit-test

{ T{ linear-cursor f 5 1 } } [
    T{ linear-cursor f 1 1 } T{ linear-cursor f 5 1 } [ value>> 6 = ] -find
] unit-test

{ { 1 3 } } [
    [ T{ linear-cursor f 1 2 } T{ linear-cursor f 5 2 } [ value>> , ] -each ]
    { } make
] unit-test

{ B{ 1 2 3 4 5 } } [ [ { 1 2 3 4 5 } [ , ] each ] B{ } make ] unit-test
{ B{ } } [ [ { } [ , ] each ] B{ } make ] unit-test
{ { 2 4 6 8 10 } } [ { 1 2 3 4 5 } [ 2 * ] map ] unit-test

{ { "roses: lutefisk" "tulips: lox" } }
[
    [
        H{ { "roses" "lutefisk" } { "tulips" "lox" } }
        [ ": " glue , ] assoc-each
    ] { } make sort
] unit-test

{ { "roses: lutefisk" "tulips: lox" } }
[
    H{ { "roses" "lutefisk" } { "tulips" "lox" } }
    [ ": " glue ] { } assoc>map sort
] unit-test

: compile-test-each ( xs -- )
    [ , ] each ;

: compile-test-map ( xs -- ys )
    [ 2 * ] map ;

: compile-test-assoc-each ( xs -- )
    [ ": " glue , ] assoc-each ;

: compile-test-assoc>map ( xs -- ys )
    [ ": " glue ] { } assoc>map ;

{ B{ 1 2 3 4 5 } } [ [ { 1 2 3 4 5 } compile-test-each ] B{ } make ] unit-test
{ { 2 4 6 8 10 } } [ { 1 2 3 4 5 } compile-test-map ] unit-test

{ { "roses: lutefisk" "tulips: lox" } }
[
    [ H{ { "roses" "lutefisk" } { "tulips" "lox" } } compile-test-assoc-each ]
    { } make sort
] unit-test

{ { "roses: lutefisk" "tulips: lox" } }
[
    H{ { "roses" "lutefisk" } { "tulips" "lox" } } compile-test-assoc>map
    sort
] unit-test
