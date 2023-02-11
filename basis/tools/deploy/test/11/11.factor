! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: eval ;
IN: tools.deploy.test.11

: foo ( -- ) "USING: math prettyprint ; 2 2 + ." eval( -- ) ;

MAIN: foo
