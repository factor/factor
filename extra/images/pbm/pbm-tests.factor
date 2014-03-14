! Copyright (C) 2010 Erik Charlebois.
! See http://factorcode.org/license.txt for BSD license.
USING: images.pbm images.testing ;
IN: images.pbm.tests

"vocab:images/testing/pbm/test.binary.pbm" pbm-image decode-test
"vocab:images/testing/pbm/test.ascii.pbm" pbm-image decode-test
