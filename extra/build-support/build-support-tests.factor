! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: build-support sequences tools.test ;
IN: build-support.tests

[ f ] [ factor.sh-make-target empty? ] unit-test
