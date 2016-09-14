! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: build-support kernel sequences system tools.test ;
IN: build-support.tests

"." install-prefix = [
    { f } [ factor.sh-make-target empty? ] unit-test
] when
