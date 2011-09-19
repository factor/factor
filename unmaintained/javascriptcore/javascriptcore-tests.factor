! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors javascriptcore kernel tools.test ;
IN: javascriptcore.tests

[ "2" ] [ "1+1" eval-js-standalone ] unit-test

[ "1+shoes" eval-js-standalone ]
[ error>> "ReferenceError: Can't find variable: shoes" = ] must-fail-with

