! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs kernel math math.intervals
namespaces sequences money math.order usa-cities
taxes.usa taxes.usa.w4 ;
IN: taxes.usa.mn

! Minnesota
: mn-single ( -- triples )
    {
        {     0  1950  decimal: 0     }
        {  1950 23750  decimal: .0535 }
        { 23750 73540  decimal: .0705 }
        { 73540 1/0.   decimal: .0785 }
    } ;

: mn-married ( -- triples )
    {
        {      0   7400 decimal: 0     }
        {   7400  39260 decimal: .0535 }
        {  39260 133980 decimal: .0705 }
        { 133980   1/0. decimal: .0785 }
    } ;

: <mn> ( -- obj )
    MN mn-single mn-married <tax-table> ;

M: MN adjust-allowances* ( salary w4 collector entity -- newsalary )
    2drop calculate-w4-allowances - ;

M: MN withholding* ( salary w4 collector entity -- x )
    drop
    [ adjust-allowances ] 2keep marriage-table tax ;
