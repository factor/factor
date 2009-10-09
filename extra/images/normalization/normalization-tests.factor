! Copyright (C) 2009 Keith Lazuka.
! See http://factorcode.org/license.txt for BSD license.
USING: images images.normalization images.normalization.private
sequences tools.test ;
IN: images.normalization.tests

! 1>x

[ B{ 255 255 } ]
[ B{ 0 1 } A L permute ] unit-test

[ B{ 255 255 255 255 } ]
[ B{ 0 1 } A RG permute ] unit-test

[ B{ 255 255 255 255 255 255 } ]
[ B{ 0 1 } A BGR permute ] unit-test

[ B{ 0 255 255 255 1 255 255 255 } ]
[ B{ 0 1 } A ABGR permute ] unit-test

! 2>x

[ B{ 0 2 } ]
[ B{ 0 1 2 3 } LA L permute ] unit-test

[ B{ 255 255 255 255 } ]
[ B{ 0 1 2 3 } LA RG permute ] unit-test

[ B{ 255 255 255 255 255 255 } ]
[ B{ 0 1 2 3 } LA BGR permute ] unit-test

[ B{ 1 255 255 255 3 255 255 255 } ]
[ B{ 0 1 2 3 } LA ABGR permute ] unit-test

! 3>x

[ B{ 255 255 } ]
[ B{ 0 1 2 3 4 5 } RGB L permute ] unit-test

[ B{ 0 1 3 4 } ]
[ B{ 0 1 2 3 4 5 } RGB RG permute ] unit-test

[ B{ 2 1 0 5 4 3 } ]
[ B{ 0 1 2 3 4 5 } RGB BGR permute ] unit-test

[ B{ 255 2 1 0 255 5 4 3 } ]
[ B{ 0 1 2 3 4 5 } RGB ABGR permute ] unit-test

! 4>x

[ B{ 255 255 } ]
[ B{ 0 1 2 3 4 5 6 7 } RGBA L permute ] unit-test

[ B{ 0 1 4 5 } ]
[ B{ 0 1 2 3 4 5 6 7 } RGBA RG permute ] unit-test

[ B{ 2 1 0 6 5 4 } ]
[ B{ 0 1 2 3 4 5 6 7 } RGBA BGR permute ] unit-test

[ B{ 3 2 1 0 7 6 5 4 } ]
[ B{ 0 1 2 3 4 5 6 7 } RGBA ABGR permute ] unit-test

! A little ad hoc testing

[ B{ 0 4 } ]
[ B{ 0 1 2 3 4 5 6 7 } RGBA R permute ] unit-test

[ B{ 255 0 1 2 255 4 5 6 } ]
[ B{ 0 1 2 3 4 5 6 7 } RGBA XRGB permute ] unit-test

[ B{ 1 2 3 255 5 6 7 255 } ]
[ B{ 0 1 2 3 4 5 6 7 } XRGB RGBA permute ] unit-test

[ B{ 255 255 255 255 255 255 255 255 } ]
[ B{ 0 1 } L RGBA permute ] unit-test

