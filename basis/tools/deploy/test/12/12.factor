! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: math.parser io math ;
IN: tools.deploy.test.12

: execute-test ( a b w -- c ) execute( a b -- c ) ;

: call-test ( a b q -- c ) call( a b -- c ) ;

: foo ( -- ) 1 2 \ + execute-test 4 [ * ] call-test number>string print ;

MAIN: foo
