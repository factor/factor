! Copyright (C) 2008 Jeff Bigot
! See http://factorcode.org/license.txt for BSD license.
USING: 
adsoda.tools
tools.test
;

IN: adsoda.tools.tests


 [ { 1 0 } ] [ { { 0 0 } { 0 1 } }  normal-vector    ] unit-test
 [ f ] [ { { 0 0 } { 0 0 } }  normal-vector    ] unit-test

 [  { 1/2 1/2 1+1/2 }  ] [ { { 1 2 } { 2 1 } }  points-to-hyperplane ] unit-test
