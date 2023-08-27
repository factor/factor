! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors math ;
IN: taxes.usa.w4

! Each employee fills out a w4
TUPLE: w4 year allowances married? ;
C: <w4> w4

: allowance ( -- x ) 3500 ; inline

: calculate-w4-allowances ( w4 -- x ) allowances>> allowance * ;
