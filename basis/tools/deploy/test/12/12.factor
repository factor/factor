! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: call math.parser io math ;
IN: tools.deploy.test.12

: execute-test ( a b w -- c ) execute( a b -- c ) ;

: foo ( -- ) 1 2 \ + execute-test number>string print ;

MAIN: foo