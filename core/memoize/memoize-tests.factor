! Copyright (C) 2007, 2009 Slava Pestov, Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: math kernel memoize tools.test parser generalizations
prettyprint io.streams.string sequences eval namespaces see ;
IN: memoize.tests

MEMO: fib ( m -- n )
    dup 1 <= [ drop 1 ] [ dup 1 - fib swap 2 - fib + ] if ;

MEMO: x ( a b c d e -- f g h i j )
    [ 1 + ] 4 ndip ;

{ 89 } [ 10 fib ] unit-test

{
    1 0 0 0 0
    1 0 0 0 0
} [
    0 0 0 0 0 x
    0 0 0 0 0 x
] unit-test

MEMO: see-test ( a -- b ) reverse ;

{ "USING: sequences ;\nIN: memoize.tests\nMEMO: see-test ( a -- b ) reverse ;\n" }
[ [ \ see-test see ] with-string-writer ]
unit-test
{ } [ "IN: memoize.tests : fib ( -- ) ;" eval( -- ) ] unit-test

{ "IN: memoize.tests\n: fib ( -- ) ;\n" } [ [ \ fib see ] with-string-writer ] unit-test

[ sq ] ( a -- b ) memoize-quot "q" set

{ 9 } [ 3 "q" get call ] unit-test

SYMBOL: foo-counter
0 foo-counter set-global

MEMO: foo ( -- ) foo-counter counter drop ;

{ 0 1 1 1 } [
    foo-counter get-global
    foo
    foo-counter get-global
    foo
    foo-counter get-global
    foo
    foo-counter get-global
] unit-test

SYMBOL: bar-counter
0 bar-counter set-global

MEMO: bar ( -- x ) bar-counter counter ;

{ 0 1 1 1 } [
    bar-counter get-global
    bar
    bar
    bar
] unit-test

SYMBOL: baz-counter
0 baz-counter set-global

MEMO: baz ( -- x ) baz-counter counter drop f ;

{ 0 f 1 f 1 f 1 } [
    baz-counter get-global
    baz
    baz-counter get-global
    baz
    baz-counter get-global
    baz
    baz-counter get-global
] unit-test
