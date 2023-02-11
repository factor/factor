! Copyright (C) 2010 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: build-support sequences tools.test ;
IN: build-support.tests

{ f } [ build-make-target empty? ] unit-test
