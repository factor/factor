! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math money ;
IN: taxes.usa.medicare

! No base rate for medicare; all wages subject
: medicare-tax-rate ( -- x ) DECIMAL: .0145 ; inline
: medicare-tax ( salary w4 -- x ) drop medicare-tax-rate * ;
