! Copyright (C) 2007, 2009 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: math kernel memoize tools.test parser generalizations
prettyprint io.streams.string sequences eval namespaces ;
IN: memoize.tests

MEMO: fib ( m -- n )
    dup 1 <= [ drop 1 ] [ dup 1 - fib swap 2 - fib + ] if ;

[ 89 ] [ 10 fib ] unit-test

[ "USING: kernel math memoize generalizations ; IN: memoize.tests MEMO: x ( a b c d e -- f g h i j ) [ 1+ ] 4 ndip ;" eval ] must-fail

MEMO: see-test ( a -- b ) reverse ;

[ "USING: memoize sequences ;\nIN: memoize.tests\nMEMO: see-test ( a -- b ) reverse ;\n" ]
[ [ \ see-test see ] with-string-writer ]
unit-test

[ ] [ "IN: memoize.tests : fib ( -- ) ;" eval ] unit-test

[ "IN: memoize.tests\n: fib ( -- ) ;\n" ] [ [ \ fib see ] with-string-writer ] unit-test

[ sq ] (( a -- b )) memoize-quot "q" set

[ 9 ] [ 3 "q" get call ] unit-test
