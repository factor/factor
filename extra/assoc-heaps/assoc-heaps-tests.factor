! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: assoc-heaps combinators heaps kernel tools.test ;

{ { { 0 "zero" } { 1 "one" } { 2 "two" } } } [
    <unique-min-heap>
    "two" 2 pick heap-push
    "zero" 0 pick heap-push
    "one" 1 pick heap-push
    heap-pop-all
] unit-test
