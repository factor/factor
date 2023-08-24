! Copyright (C) 2009 Keith Lazuka.
! See https://factorcode.org/license.txt for BSD license.
USING: images images.normalization images.normalization.private
sequences tools.test ;
IN: images.normalization.tests

! 1>x

{ B{ 255 255 } }
[ B{ 0 1 } 2 2 A L permute ] unit-test

{ B{ 255 255 255 255 } }
[ B{ 0 1 } 2 2 A RG permute ] unit-test

{ B{ 255 255 255 255 255 255 } }
[ B{ 0 1 } 2 2 A BGR permute ] unit-test

{ B{ 0 255 255 255 1 255 255 255 } }
[ B{ 0 1 } 2 2 A ABGR permute ] unit-test

! Difference stride
! The last byte is padding, so it should not end up in the image

{ B{ 255 255 } }
[ B{ 0 1 0 } 2 3 A L permute ] unit-test

{ B{ 255 255 255 255 } }
[ B{ 0 1 0 } 2 3 A RG permute ] unit-test

{ B{ 255 255 255 255 255 255 } }
[ B{ 0 1 0 } 2 3 A BGR permute ] unit-test

{ B{ 0 255 255 255 1 255 255 255 } }
[ B{ 0 1 0 } 2 3 A ABGR permute ] unit-test

! 2>x

{ B{ 0 2 } }
[ B{ 0 1 2 3 } 2 4 LA L permute ] unit-test

{ B{ 255 255 255 255 } }
[ B{ 0 1 2 3 } 2 4 LA RG permute ] unit-test

{ B{ 255 255 255 255 255 255 } }
[ B{ 0 1 2 3 } 2 4 LA BGR permute ] unit-test

{ B{ 1 255 255 255 3 255 255 255 } }
[ B{ 0 1 2 3 } 2 4 LA ABGR permute ] unit-test

! 3>x

{ B{ 255 255 } }
[ B{ 0 1 2 3 4 5 } 2 6 RGB L permute ] unit-test

{ B{ 0 1 3 4 } }
[ B{ 0 1 2 3 4 5 } 2 6 RGB RG permute ] unit-test

{ B{ 2 1 0 5 4 3 } }
[ B{ 0 1 2 3 4 5 } 2 6 RGB BGR permute ] unit-test

{ B{ 255 2 1 0 255 5 4 3 } }
[ B{ 0 1 2 3 4 5 } 2 6 RGB ABGR permute ] unit-test

! 4>x

{ B{ 255 255 } }
[ B{ 0 1 2 3 4 5 6 7 } 2 8 RGBA L permute ] unit-test

{ B{ 0 1 4 5 } }
[ B{ 0 1 2 3 4 5 6 7 } 2 8 RGBA RG permute ] unit-test

{ B{ 2 1 0 6 5 4 } }
[ B{ 0 1 2 3 4 5 6 7 } 2 8 RGBA BGR permute ] unit-test

{ B{ 3 2 1 0 7 6 5 4 } }
[ B{ 0 1 2 3 4 5 6 7 } 2 8 RGBA ABGR permute ] unit-test

! Edge cases

{ B{ 0 4 } }
[ B{ 0 1 2 3 4 5 6 7 } 2 8 RGBA R permute ] unit-test

{ B{ 255 0 1 2 255 4 5 6 } }
[ B{ 0 1 2 3 4 5 6 7 } 2 8 RGBA XRGB permute ] unit-test

{ B{ 1 2 3 255 5 6 7 255 } }
[ B{ 0 1 2 3 4 5 6 7 } 2 8 XRGB RGBA permute ] unit-test

{ B{ 255 255 255 255 255 255 255 255 } }
[ B{ 0 1 } 2 2 L RGBA permute ] unit-test

! Invalid inputs

[
    T{ image f { 1 1 } DEPTH ubyte-components f B{ 0 } }
    RGB reorder-components
] must-fail

[
    T{ image f { 1 1 } DEPTH-STENCIL ubyte-components f B{ 0 } }
    RGB reorder-components
] must-fail

[
    T{ image f { 1 1 } INTENSITY ubyte-components f B{ 0 } }
    RGB reorder-components
] must-fail

[
    T{ image f { 1 1 } RGB ubyte-components f B{ 0 0 0 } }
    DEPTH reorder-components
] must-fail

[
    T{ image f { 1 1 } RGB ubyte-components f B{ 0 0 0 } }
    DEPTH-STENCIL reorder-components
] must-fail

[
    T{ image f { 1 1 } RGB ubyte-components f B{ 0 0 0 } }
    INTENSITY reorder-components
] must-fail
