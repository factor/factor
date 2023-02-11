! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel tools.test usa-cities ;

{ t } [ 55406 find-zip-code name>> "Minneapolis" = ] unit-test
