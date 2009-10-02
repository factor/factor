! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: images.png images.testing namespaces tools.test
tools.test.private ;
IN: images.png.tests

verbose-tests? off
"vocab:images/testing/png/rgb.png" decode-test
"vocab:images/testing/png/yin_yang.png" decode-test
verbose-tests? on
