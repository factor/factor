USING: accessors fluids images.loader tools.test ;
IN: fluids.tests

! #2871: loading the demo must also load decoders for both bundled textures.
{ { 128 128 } } [ "vocab:fluids/particle2.pgm" load-image dim>> ] unit-test
{ { 10 1 } } [ "vocab:fluids/colors.ppm" load-image dim>> ] unit-test
