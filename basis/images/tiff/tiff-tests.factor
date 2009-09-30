! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors images.testing images.tiff images.viewer io
io.encodings.binary io.files namespaces sequences tools.test
tools.test.private ;
IN: images.tiff.tests

verbose-tests? off
"vocab:images/testing/tiff/octagon.tiff" decode-test
"vocab:images/testing/tiff/elephants.tiff" decode-test
"vocab:images/testing/tiff/noise.tiff" decode-test
"vocab:images/testing/tiff/alpha.tiff" decode-test
"vocab:images/testing/tiff/color_spectrum.tiff" decode-test
! "vocab:images/testing/tiff/rgb.tiff" decode-test
verbose-tests? on
