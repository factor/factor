! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel tools.test usa-cities ;
IN: usa-cities.tests

[ t ] [ 55406 find-zip-code name>> "Minneapolis" = ] unit-test
