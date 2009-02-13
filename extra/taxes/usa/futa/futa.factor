! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs kernel math math.intervals
namespaces sequences money math.order ;
IN: taxes.usa.futa

! Employer tax only, not withheld
: futa-tax-rate ( -- x ) DECIMAL: .062 ; inline
: futa-base-rate ( -- x ) 7000 ; inline
: futa-tax-offset-credit ( -- x ) DECIMAL: .054 ; inline

: futa-tax ( salary w4 -- x )
    drop futa-base-rate min
    futa-tax-rate futa-tax-offset-credit - * ;
