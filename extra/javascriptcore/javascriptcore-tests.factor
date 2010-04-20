! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors javascriptcore kernel tools.test ;
IN: javascriptcore.tests

[ "2" ] [ "1+1" eval-js ] unit-test

[ "1+shoes" eval-js ]
[ error>> "ReferenceError: Can't find variable: shoes" = ] must-fail-with

