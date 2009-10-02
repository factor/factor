! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors images.testing images.tiff images.viewer io
io.encodings.binary io.files namespaces sequences tools.test
images.pam ;
IN: images.tiff.tests

"vocab:images/testing/tiff/octagon.tiff" decode-test
"vocab:images/testing/tiff/elephants.tiff" decode-test
"vocab:images/testing/tiff/noise.tiff" decode-test
"vocab:images/testing/tiff/alpha.tiff" decode-test
"vocab:images/testing/tiff/color_spectrum.tiff" decode-test
! "vocab:images/testing/tiff/rgb.tiff" decode-test
