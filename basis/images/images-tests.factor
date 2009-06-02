! Copyright (C) 2009 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: images tools.test kernel accessors ;
IN: images.tests

[ B{ 57 57 57 255 } ] [ 1 1 T{ image f { 2 3 } RGBA f B{
    0 0 0 0 
    0 0 0 0 
    0 0 0 0 
    0 0 0 0 
    57 57 57 255
    0 0 0 0 
} } pixel-at ] unit-test

[ B{
    0 0 0 0 
    0 0 0 0 
    0 0 0 0 
    0 0 0 0 
    57 57 57 255
    0 0 0 0 
} ] [ B{ 57 57 57 255 } 1 1 T{ image f { 2 3 } RGBA f B{
    0 0 0 0 
    0 0 0 0 
    0 0 0 0 
    0 0 0 0 
    0 0 0 0 
    0 0 0 0 
} } [ set-pixel-at ] keep bitmap>> ] unit-test
