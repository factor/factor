! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math money taxes.usa taxes.usa.w4 usa-cities ;
IN: taxes.usa.mn

! Minnesota
: mn-single ( -- triples )
    {
        {     0  1950  DECIMAL: 0     }
        {  1950 23750  DECIMAL: .0535 }
        { 23750 73540  DECIMAL: .0705 }
        { 73540 1/0.   DECIMAL: .0785 }
    } ;

: mn-married ( -- triples )
    {
        {      0   7400 DECIMAL: 0     }
        {   7400  39260 DECIMAL: .0535 }
        {  39260 133980 DECIMAL: .0705 }
        { 133980   1/0. DECIMAL: .0785 }
    } ;

: <mn> ( -- obj )
    MN mn-single mn-married <tax-table> ;

M: MN adjust-allowances* ( salary w4 collector entity -- newsalary )
    2drop calculate-w4-allowances - ;

M: MN withholding* ( salary w4 collector entity -- x )
    drop
    [ adjust-allowances ] 2keep marriage-table tax ;
