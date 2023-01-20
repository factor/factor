! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel math money taxes.usa taxes.usa.fica
taxes.usa.medicare taxes.usa.w4 ;
IN: taxes.usa.federal

! https://www.irs.gov/pub/irs-pdf/p15.pdf
! Table 7 ANNUAL Payroll Period

: federal-single ( -- triples )
    {
        {      0   2650 DECIMAL: 0   }
        {   2650  10300 DECIMAL: .10 }
        {  10300  33960 DECIMAL: .15 }
        {  33960  79725 DECIMAL: .25 }
        {  79725 166500 DECIMAL: .28 }
        { 166500 359650 DECIMAL: .33 }
        { 359650   1/0. DECIMAL: .35 }
    } ;

: federal-married ( -- triples )
    {
        {      0   8000 DECIMAL: 0   }
        {   8000  23550 DECIMAL: .10 }
        {  23550  72150 DECIMAL: .15 }
        {  72150 137850 DECIMAL: .25 }
        { 137850 207700 DECIMAL: .28 }
        { 207700 365100 DECIMAL: .33 }
        { 365100   1/0. DECIMAL: .35 }
    } ;

SINGLETON: federal
: <federal> ( -- obj )
    federal federal-single federal-married <tax-table> ;

: federal-tax ( salary w4 tax-table -- n )
    [ adjust-allowances ] 2keep marriage-table tax ;

M: federal adjust-allowances* ( salary w4 collector entity -- newsalary )
    2drop calculate-w4-allowances - ;

M: federal withholding* ( salary w4 tax-table entity -- x )
    drop
    [ federal-tax ] 2keepd
    [ fica-tax ] 2keep
    medicare-tax + + ;

: total-withholding ( salary w4 tax-table -- x )
    dup entity>> dup federal = [
        withholding*
    ] [
        drop
        [ drop <federal> federal withholding* ]
        [ dup entity>> withholding* ] 3bi +
    ] if ;

: net ( salary w4 collector -- x )
    [ dupd ] dip total-withholding - ;
