! Copyright (C) 2017 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test syntax.extras ;
IN: syntax.extras.tests

<ARRAY: nums1 1 2 3 ;ARRAY>
CONSTANT: nums2 <array 1 2 3 array>

UNIT-TEST: [ nums1 ] { { 1 2 3 } }
UNIT-TEST: [ nums2 ] { { 1 2 3 } }

