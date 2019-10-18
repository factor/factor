! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: html.parser.analyzer math tools.test ;
IN: html.parser.analyzer.tests

[ 0 3 ]
[ 1 { 3 5 7 9 11 } [ odd? ] find-nth ] unit-test

[ 2 7 ]
[ 3 { 3 5 7 9 11 } [ odd? ] find-nth ] unit-test

[ 3 9 ]
[ 3 1 { 3 5 7 9 11 } [ odd? ] find-nth-from ] unit-test

[ 4 11 ]
[ 1 { 3 5 7 9 11 } [ odd? ] find-last-nth ] unit-test

[ 2 7 ]
[ 3 { 3 5 7 9 11 } [ odd? ] find-last-nth ] unit-test

[ 0 3 ]
[ 1 2 { 3 5 7 9 11 } [ odd? ] find-last-nth-from ] unit-test


[ 0 { 3 5 7 9 11 } [ odd? ] find-nth ]
[ undefined-find-nth? ] must-fail-with

[ 0 { 3 5 7 9 11 } [ odd? ] find-last-nth ]
[ undefined-find-nth? ] must-fail-with
